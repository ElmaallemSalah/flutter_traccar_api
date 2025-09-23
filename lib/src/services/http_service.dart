import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/error_handler.dart';
import 'cache_manager.dart';
import 'cache_interceptor.dart';
import 'rate_limiter.dart';
import 'rate_limit_interceptor.dart';
import 'request_batcher.dart';

/// Configuration class for HTTP client settings
class HttpClientConfig {
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final int maxRetries;
  final Duration retryDelay;
  final bool enableLogging;
  final bool enableCaching;
  final bool enableOfflineMode;
  final CacheConfig? cacheConfig;
  final List<int> retryStatusCodes;

  /// Enable rate limiting
  final bool enableRateLimiting;

  /// Rate limiting configuration
  final RateLimitConfig rateLimitConfig;

  /// Enable request batching
  final bool enableBatching;

  /// Batching configuration
  final BatchConfig batchConfig;

  const HttpClientConfig({
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.enableLogging = kDebugMode,
    this.enableCaching = true,
    this.enableOfflineMode = true,
    this.cacheConfig,
    this.retryStatusCodes = const [502, 503, 504, 408, 429],
    this.enableRateLimiting = true,
    this.rateLimitConfig = RateLimitConfig.traccarDefault,
    this.enableBatching = false,
    this.batchConfig = BatchConfig.traccarDefault,
  });
}

/// Base HTTP service class that handles all network requests
/// with Dio integration, authentication support, rate limiting, batching, and advanced features
class HttpService with BatchingCapable {
  late final Dio _dio;
  String? _baseUrl;
  String? _basicAuthToken;
  final HttpClientConfig _config;

  /// Creates an instance of HttpService with optional base URL and configuration
  HttpService({
    String? baseUrl,
    HttpClientConfig? config,
  }) : _config = config ?? const HttpClientConfig() {
    _baseUrl = baseUrl;
    _dio = Dio(BaseOptions(
      connectTimeout: _config.connectTimeout,
      receiveTimeout: _config.receiveTimeout,
      sendTimeout: _config.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Initialize batching if enabled
    if (_config.enableBatching) {
      initializeBatching(_dio, _config.batchConfig);
    }

    _initializeInterceptors();
  }

  /// Initialize all interceptors
  void _initializeInterceptors() {
    // Add rate limiting interceptor if enabled
    if (_config.enableRateLimiting) {
      final rateLimitInterceptor = RateLimitInterceptorFactory.create(
        key: 'traccar_api',
        config: RateLimitInterceptorConfig(
          rateLimitConfig: _config.rateLimitConfig,
          enableLogging: kDebugMode,
        ),
      );
      _dio.interceptors.add(rateLimitInterceptor);
    }

    // Initialize cache manager if caching is enabled
    if (_config.enableCaching) {
      CacheManager.instance.initialize(_config.cacheConfig);
      
      // Add cache interceptor
      _dio.interceptors.add(CacheInterceptor(
        config: CacheInterceptorConfig(
          enableCaching: _config.enableCaching,
          enableOfflineMode: _config.enableOfflineMode,
        ),
      ));
    }

    // Add logging interceptor if enabled
    if (_config.enableLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    // Add retry interceptor
    final retryInterceptor = _RetryInterceptor(_config);
    retryInterceptor.setDio(_dio);
    _dio.interceptors.add(retryInterceptor);

    // Add main request/response interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add base URL if provided
          if (_baseUrl != null && !options.path.startsWith('http')) {
            options.baseUrl = _baseUrl!;
          }

          // Add basic auth header if token is available
          if (_basicAuthToken != null) {
            options.headers['Authorization'] = 'Basic $_basicAuthToken';
          }

          // Set default content type only for requests with body (POST, PUT, PATCH)
          if (!options.headers.containsKey('Content-Type') && 
              ['POST', 'PUT', 'PATCH'].contains(options.method.toUpperCase())) {
            options.headers['Content-Type'] = 'application/json';
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          // Handle common HTTP errors
          if (error.response?.statusCode == 401) {
            // Clear auth token on unauthorized
            _basicAuthToken = null;
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Sets the base URL for all requests
  void setBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
  }

  /// Sets the basic authentication token
  void setBasicAuthToken(String username, String password) {
    final credentials = base64Encode(utf8.encode('$username:$password'));
    _basicAuthToken = credentials;
  }

  /// Clears the authentication token
  void clearAuthToken() {
    _basicAuthToken = null;
  }

  /// Get cache manager instance
  CacheManager get cacheManager => CacheManager.instance;

  /// Get cached data for a specific endpoint
  Future<T?> getCached<T>(String endpoint, {T Function(Map<String, dynamic>)? fromJson}) async {
    if (!_config.enableCaching) return null;
    
    final cacheKey = 'GET|$endpoint';
    final cachedEntry = await cacheManager.get(cacheKey);
    
    if (cachedEntry != null) {
      try {
        final data = jsonDecode(cachedEntry.data);
        if (fromJson != null && data is Map<String, dynamic>) {
          return fromJson(data);
        }
        return data as T?;
      } catch (e) {
        debugPrint('Error parsing cached data: $e');
      }
    }
    
    return null;
  }

  /// Invalidate cache for specific endpoint
  Future<void> invalidateCache(String endpoint) async {
    if (!_config.enableCaching) return;
    
    final cacheKey = 'GET|$endpoint';
    await cacheManager.remove(cacheKey);
  }

  /// Clear all cache
  Future<void> clearCache() async {
    if (!_config.enableCaching) return;
    
    await cacheManager.clear();
  }

  /// Get cache statistics
  Future<CacheStats> getCacheStats() async {
    return await cacheManager.getStats();
  }

  // Rate Limiting Methods

  /// Get rate limit status
  RateLimitStatus? getRateLimitStatus() {
    if (!_config.enableRateLimiting) return null;
    
    final rateLimiter = RateLimiterManager.getLimiter('traccar_api');
    return rateLimiter.getStatus();
  }

  /// Reset rate limiter
  void resetRateLimit() {
    if (!_config.enableRateLimiting) return;
    
    final rateLimiter = RateLimiterManager.getLimiter('traccar_api');
    rateLimiter.reset();
  }

  // Batching Methods

  /// Make a batched GET request
  Future<Response<T>> batchedGet<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!_config.enableBatching) {
      return get<T>(path, queryParameters: queryParameters, options: options);
    }

    return batchedRequest<T>(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Get batch statistics
  BatchStats? getBatchingStats() {
    return getBatchStats();
  }

  /// Flush all pending batches
  Future<void> flushAllBatches() async {
    await flushBatches();
  }

  /// Performs a GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await ErrorHandler.wrapAsync(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      ),
      context: 'GET $path',
    );
  }

  /// Performs a POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await ErrorHandler.wrapAsync(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      context: 'POST $path',
    );
  }

  /// Performs a PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await ErrorHandler.wrapAsync(
      () => _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      context: 'PUT $path',
    );
  }

  /// Performs a DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await ErrorHandler.wrapAsync(
      () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      context: 'DELETE $path',
    );
  }

  /// Gets the current Dio instance for advanced usage
  Dio get dio => _dio;

  /// Checks if authentication token is set
  bool get isAuthenticated => _basicAuthToken != null;

  /// Gets the current HTTP client configuration
  HttpClientConfig get config => _config;
}

/// Retry interceptor for handling failed requests with exponential backoff
class _RetryInterceptor extends Interceptor {
  final HttpClientConfig _config;
  late final Dio _dio;

  _RetryInterceptor(this._config);

  void setDio(Dio dio) {
    _dio = dio;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = (extra['retryCount'] as int?) ?? 0;

    // Check if we should retry this request
    if (_shouldRetry(err, retryCount)) {
      try {
        // Calculate delay with exponential backoff
        final delay = Duration(
          milliseconds: _config.retryDelay.inMilliseconds * (retryCount + 1),
        );
        
        await Future.delayed(delay);

        // Update retry count
        err.requestOptions.extra['retryCount'] = retryCount + 1;

        // Retry the request
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // If retry fails, continue with original error
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err, int retryCount) {
    // Don't retry if we've exceeded max retries
    if (retryCount >= _config.maxRetries) {
      return false;
    }

    // Don't retry for certain error types
    if (err.type == DioExceptionType.cancel ||
        err.type == DioExceptionType.unknown) {
      return false;
    }

    // Retry for network errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }

    // Retry for specific HTTP status codes
    final statusCode = err.response?.statusCode;
    if (statusCode != null && _config.retryStatusCodes.contains(statusCode)) {
      return true;
    }

    return false;
  }
}