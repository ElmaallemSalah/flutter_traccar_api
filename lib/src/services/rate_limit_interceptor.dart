import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'rate_limiter.dart';

/// Dio interceptor for rate limiting
class RateLimitInterceptor extends Interceptor {
  final RateLimiter _rateLimiter;
  final bool _enableLogging;

  RateLimitInterceptor({
    required RateLimiter rateLimiter,
    bool enableLogging = false,
  }) : _rateLimiter = rateLimiter,
       _enableLogging = enableLogging;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      if (_enableLogging) {
        final status = _rateLimiter.getStatus();
        debugPrint('Rate limit status before request: $status');
      }

      // Wait for permission to make the request
      await _rateLimiter.waitForPermission();

      if (_enableLogging) {
        debugPrint('Rate limit permission granted for: ${options.method} ${options.path}');
      }

      handler.next(options);
    } catch (e) {
      if (e is RateLimitException) {
        final dioError = DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          message: e.message,
          error: e,
        );
        handler.reject(dioError);
      } else {
        handler.reject(DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          message: 'Rate limiting error: $e',
          error: e,
        ));
      }
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_enableLogging) {
      final status = _rateLimiter.getStatus();
      debugPrint('Rate limit status after response: $status');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_enableLogging) {
      final status = _rateLimiter.getStatus();
      debugPrint('Rate limit status after error: $status');
    }

    // Check if this is a rate limit error from the server
    if (err.response?.statusCode == 429) {
      final retryAfter = _parseRetryAfter(err.response?.headers);
      final rateLimitError = RateLimitException(
        'Server rate limit exceeded. ${retryAfter != null ? "Retry after ${retryAfter.inSeconds} seconds." : ""}',
        _rateLimiter.getStatus(),
      );
      
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        type: DioExceptionType.unknown,
        message: rateLimitError.message,
        error: rateLimitError,
        response: err.response,
      ));
    } else {
      handler.next(err);
    }
  }

  /// Parse Retry-After header from response
  Duration? _parseRetryAfter(Headers? headers) {
    if (headers == null) return null;

    final retryAfterValues = headers['retry-after'];
    if (retryAfterValues == null || retryAfterValues.isEmpty) return null;

    final retryAfterValue = retryAfterValues.first;
    
    // Try to parse as seconds
    final seconds = int.tryParse(retryAfterValue);
    if (seconds != null) {
      return Duration(seconds: seconds);
    }

    // Try to parse as HTTP date (not implemented for simplicity)
    return null;
  }
}

/// Configuration for rate limiting interceptor
class RateLimitInterceptorConfig {
  final RateLimitConfig rateLimitConfig;
  final bool enableLogging;
  final String? limiterKey;

  const RateLimitInterceptorConfig({
    this.rateLimitConfig = RateLimitConfig.traccarDefault,
    this.enableLogging = false,
    this.limiterKey,
  });
}

/// Factory for creating rate limit interceptors
class RateLimitInterceptorFactory {
  static final Map<String, RateLimitInterceptor> _interceptors = {};

  /// Create or get a rate limit interceptor
  static RateLimitInterceptor create({
    String key = 'default',
    RateLimitInterceptorConfig? config,
  }) {
    return _interceptors.putIfAbsent(key, () {
      final effectiveConfig = config ?? const RateLimitInterceptorConfig();
      final rateLimiter = RateLimiterManager.getLimiter(
        effectiveConfig.limiterKey ?? key,
        effectiveConfig.rateLimitConfig,
      );
      
      return RateLimitInterceptor(
        rateLimiter: rateLimiter,
        enableLogging: effectiveConfig.enableLogging,
      );
    });
  }

  /// Remove an interceptor
  static void remove(String key) {
    final interceptor = _interceptors.remove(key);
    if (interceptor != null) {
      RateLimiterManager.removeLimiter(key);
    }
  }

  /// Clear all interceptors
  static void clearAll() {
    _interceptors.clear();
    RateLimiterManager.clearAll();
  }

  /// Get all interceptor keys
  static List<String> getKeys() {
    return _interceptors.keys.toList();
  }
}