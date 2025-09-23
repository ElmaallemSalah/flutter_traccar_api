import 'dart:async';
import 'dart:collection';

/// Configuration for rate limiting
class RateLimitConfig {
  /// Maximum number of requests per time window
  final int maxRequests;
  
  /// Time window duration
  final Duration timeWindow;
  
  /// Whether to queue requests when limit is exceeded
  final bool queueRequests;
  
  /// Maximum queue size (0 = unlimited)
  final int maxQueueSize;
  
  /// Delay between retries when rate limited
  final Duration retryDelay;

  const RateLimitConfig({
    this.maxRequests = 100,
    this.timeWindow = const Duration(minutes: 1),
    this.queueRequests = true,
    this.maxQueueSize = 50,
    this.retryDelay = const Duration(seconds: 1),
  });

  /// Default configuration for Traccar API
  static const RateLimitConfig traccarDefault = RateLimitConfig(
    maxRequests: 60,
    timeWindow: Duration(minutes: 1),
    queueRequests: true,
    maxQueueSize: 30,
    retryDelay: Duration(milliseconds: 500),
  );

  /// Conservative configuration for slower servers
  static const RateLimitConfig conservative = RateLimitConfig(
    maxRequests: 30,
    timeWindow: Duration(minutes: 1),
    queueRequests: true,
    maxQueueSize: 20,
    retryDelay: Duration(seconds: 2),
  );

  /// Aggressive configuration for high-performance servers
  static const RateLimitConfig aggressive = RateLimitConfig(
    maxRequests: 200,
    timeWindow: Duration(minutes: 1),
    queueRequests: false,
    maxQueueSize: 0,
    retryDelay: Duration(milliseconds: 100),
  );
}

/// Rate limiter implementation using token bucket algorithm
class RateLimiter {
  final RateLimitConfig _config;
  final Queue<DateTime> _requestTimes = Queue<DateTime>();
  final Queue<Completer<void>> _requestQueue = Queue<Completer<void>>();
  Timer? _processQueueTimer;
  bool _isProcessingQueue = false;

  RateLimiter(this._config);

  /// Check if a request can be made immediately
  bool canMakeRequest() {
    _cleanOldRequests();
    return _requestTimes.length < _config.maxRequests;
  }

  /// Wait for permission to make a request
  Future<void> waitForPermission() async {
    if (canMakeRequest()) {
      _recordRequest();
      return;
    }

    if (!_config.queueRequests) {
      throw RateLimitException(
        'Rate limit exceeded. Max ${_config.maxRequests} requests per ${_config.timeWindow.inMinutes} minutes.',
      );
    }

    if (_config.maxQueueSize > 0 && _requestQueue.length >= _config.maxQueueSize) {
      throw RateLimitException(
        'Request queue is full. Maximum ${_config.maxQueueSize} queued requests allowed.',
      );
    }

    final completer = Completer<void>();
    _requestQueue.add(completer);
    _startQueueProcessor();
    
    return completer.future;
  }

  /// Record a successful request
  void _recordRequest() {
    _requestTimes.add(DateTime.now());
  }

  /// Remove old requests outside the time window
  void _cleanOldRequests() {
    final cutoff = DateTime.now().subtract(_config.timeWindow);
    while (_requestTimes.isNotEmpty && _requestTimes.first.isBefore(cutoff)) {
      _requestTimes.removeFirst();
    }
  }

  /// Start processing the request queue
  void _startQueueProcessor() {
    if (_isProcessingQueue || _requestQueue.isEmpty) return;

    _isProcessingQueue = true;
    _processQueueTimer = Timer.periodic(_config.retryDelay, (_) {
      _processQueue();
    });
  }

  /// Process queued requests
  void _processQueue() {
    if (_requestQueue.isEmpty) {
      _stopQueueProcessor();
      return;
    }

    if (canMakeRequest()) {
      final completer = _requestQueue.removeFirst();
      _recordRequest();
      completer.complete();
    }
  }

  /// Stop processing the request queue
  void _stopQueueProcessor() {
    _processQueueTimer?.cancel();
    _processQueueTimer = null;
    _isProcessingQueue = false;
  }

  /// Get current rate limit status
  RateLimitStatus getStatus() {
    _cleanOldRequests();
    return RateLimitStatus(
      requestsInWindow: _requestTimes.length,
      maxRequests: _config.maxRequests,
      timeWindow: _config.timeWindow,
      queuedRequests: _requestQueue.length,
      canMakeRequest: canMakeRequest(),
      timeUntilReset: _getTimeUntilReset(),
    );
  }

  /// Get time until rate limit resets
  Duration _getTimeUntilReset() {
    if (_requestTimes.isEmpty) return Duration.zero;
    
    final oldestRequest = _requestTimes.first;
    final resetTime = oldestRequest.add(_config.timeWindow);
    final now = DateTime.now();
    
    return resetTime.isAfter(now) ? resetTime.difference(now) : Duration.zero;
  }

  /// Clear all queued requests and reset state
  void reset() {
    _requestTimes.clear();
    
    // Complete all queued requests with an error
    while (_requestQueue.isNotEmpty) {
      final completer = _requestQueue.removeFirst();
      completer.completeError(RateLimitException('Rate limiter was reset'));
    }
    
    _stopQueueProcessor();
  }

  /// Dispose of the rate limiter
  void dispose() {
    reset();
  }
}

/// Rate limit status information
class RateLimitStatus {
  final int requestsInWindow;
  final int maxRequests;
  final Duration timeWindow;
  final int queuedRequests;
  final bool canMakeRequest;
  final Duration timeUntilReset;

  const RateLimitStatus({
    required this.requestsInWindow,
    required this.maxRequests,
    required this.timeWindow,
    required this.queuedRequests,
    required this.canMakeRequest,
    required this.timeUntilReset,
  });

  /// Get remaining requests in current window
  int get remainingRequests => maxRequests - requestsInWindow;

  /// Get utilization percentage (0.0 to 1.0)
  double get utilization => requestsInWindow / maxRequests;

  @override
  String toString() {
    return 'RateLimitStatus('
        'requests: $requestsInWindow/$maxRequests, '
        'queued: $queuedRequests, '
        'canMake: $canMakeRequest, '
        'resetIn: ${timeUntilReset.inSeconds}s'
        ')';
  }
}

/// Exception thrown when rate limits are exceeded
class RateLimitException implements Exception {
  final String message;
  final RateLimitStatus? status;

  const RateLimitException(this.message, [this.status]);

  @override
  String toString() => 'RateLimitException: $message';
}

/// Global rate limiter manager
class RateLimiterManager {
  static final Map<String, RateLimiter> _limiters = {};

  /// Get or create a rate limiter for a specific key
  static RateLimiter getLimiter(String key, [RateLimitConfig? config]) {
    return _limiters.putIfAbsent(
      key,
      () => RateLimiter(config ?? RateLimitConfig.traccarDefault),
    );
  }

  /// Remove a rate limiter
  static void removeLimiter(String key) {
    final limiter = _limiters.remove(key);
    limiter?.dispose();
  }

  /// Clear all rate limiters
  static void clearAll() {
    for (final limiter in _limiters.values) {
      limiter.dispose();
    }
    _limiters.clear();
  }

  /// Get status of all rate limiters
  static Map<String, RateLimitStatus> getAllStatus() {
    return _limiters.map((key, limiter) => MapEntry(key, limiter.getStatus()));
  }
}