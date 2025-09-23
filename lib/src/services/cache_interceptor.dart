import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'cache_manager.dart';

/// Configuration for cache interceptor
class CacheInterceptorConfig {
  final bool enableCaching;
  final bool enableOfflineMode;
  final Set<String> cacheableMethods;
  final Set<String> nonCacheableEndpoints;
  final Map<String, Duration> endpointTtls;
  final bool respectCacheHeaders;

  const CacheInterceptorConfig({
    this.enableCaching = true,
    this.enableOfflineMode = true,
    this.cacheableMethods = const {'GET'},
    this.nonCacheableEndpoints = const {'/api/session', '/login', '/logout'},
    this.endpointTtls = const {},
    this.respectCacheHeaders = true,
  });
}

/// Dio interceptor for automatic API response caching
class CacheInterceptor extends Interceptor {
  final CacheManager _cacheManager;
  final CacheInterceptorConfig _config;

  CacheInterceptor({CacheManager? cacheManager, CacheInterceptorConfig? config})
    : _cacheManager = cacheManager ?? CacheManager.instance,
      _config = config ?? const CacheInterceptorConfig();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_shouldCache(options)) {
      handler.next(options);
      return;
    }

    final cacheKey = _generateCacheKey(options);
    final cachedEntry = await _cacheManager.get(cacheKey);

    if (cachedEntry != null) {
      // Add conditional headers if available
      if (cachedEntry.etag.isNotEmpty) {
        options.headers['If-None-Match'] = cachedEntry.etag;
      }

      // Check if we should serve from cache
      if (_config.enableOfflineMode || !_isNetworkAvailable()) {
        final response = _createResponseFromCache(options, cachedEntry);
        handler.resolve(response);
        return;
      }
    }

    // Add cache key to request for use in response handler
    options.extra['cache_key'] = cacheKey;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final cacheKey = response.requestOptions.extra['cache_key'] as String?;

    if (cacheKey != null && _shouldCacheResponse(response)) {
      await _cacheResponse(cacheKey, response);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Try to serve from cache if network error and offline mode is enabled
    if (_isNetworkError(err) && _config.enableOfflineMode) {
      final cacheKey = err.requestOptions.extra['cache_key'] as String?;

      if (cacheKey != null) {
        final cachedEntry = await _cacheManager.get(cacheKey);

        if (cachedEntry != null) {
          final response = _createResponseFromCache(
            err.requestOptions,
            cachedEntry,
          );
          handler.resolve(response);
          return;
        }
      }
    }

    handler.next(err);
  }

  /// Check if request should be cached
  bool _shouldCache(RequestOptions options) {
    if (!_config.enableCaching) return false;

    // Check method
    if (!_config.cacheableMethods.contains(options.method.toUpperCase())) {
      return false;
    }

    // Check if endpoint is in non-cacheable list
    final path = options.path;
    for (final endpoint in _config.nonCacheableEndpoints) {
      if (path.contains(endpoint)) {
        return false;
      }
    }

    return true;
  }

  /// Check if response should be cached
  bool _shouldCacheResponse(Response response) {
    // Don't cache error responses
    if (response.statusCode == null || response.statusCode! >= 400) {
      return false;
    }

    // Check cache-control headers if respecting them
    if (_config.respectCacheHeaders) {
      final cacheControl = response.headers.value('cache-control');
      if (cacheControl != null) {
        if (cacheControl.contains('no-cache') ||
            cacheControl.contains('no-store') ||
            cacheControl.contains('private')) {
          return false;
        }
      }
    }

    return true;
  }

  /// Generate cache key for request
  String _generateCacheKey(RequestOptions options) {
    final uri = options.uri;
    final method = options.method.toUpperCase();
    final queryParams = uri.queryParameters;

    // Create a consistent key from method, path, and sorted query parameters
    final sortedParams = Map.fromEntries(
      queryParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    final keyComponents = [
      method,
      uri.path,
      if (sortedParams.isNotEmpty) jsonEncode(sortedParams),
    ];

    return keyComponents.join('|');
  }

  /// Cache the response
  Future<void> _cacheResponse(String cacheKey, Response response) async {
    try {
      final data = jsonEncode(response.data);
      final etag = response.headers.value('etag') ?? '';
      final headers = <String, String>{};

      // Extract relevant headers
      for (final entry in response.headers.map.entries) {
        if (entry.value.isNotEmpty) {
          headers[entry.key] = entry.value.first;
        }
      }

      // Determine TTL
      Duration? ttl;

      // Check for endpoint-specific TTL
      final path = response.requestOptions.path;
      for (final endpoint in _config.endpointTtls.keys) {
        if (path.contains(endpoint)) {
          ttl = _config.endpointTtls[endpoint];
          break;
        }
      }

      // Check cache-control header for max-age
      if (ttl == null && _config.respectCacheHeaders) {
        final cacheControl = response.headers.value('cache-control');
        if (cacheControl != null) {
          final maxAgeMatch = RegExp(r'max-age=(\d+)').firstMatch(cacheControl);
          if (maxAgeMatch != null) {
            final seconds = int.tryParse(maxAgeMatch.group(1)!);
            if (seconds != null) {
              ttl = Duration(seconds: seconds);
            }
          }
        }
      }

      await _cacheManager.put(
        cacheKey,
        data,
        ttl: ttl,
        etag: etag,
        headers: headers,
      );
    } catch (e) {
      debugPrint('Error caching response: $e');
    }
  }

  /// Create response from cached data
  Response _createResponseFromCache(RequestOptions options, CacheEntry entry) {
    final data = jsonDecode(entry.data);

    return Response(
      requestOptions: options,
      data: data,
      statusCode: 200,
      statusMessage: 'OK (from cache)',
      headers: Headers.fromMap({
        'x-cache': ['HIT'],
        'x-cache-timestamp': [entry.timestamp.toIso8601String()],
        ...entry.headers.map((key, value) => MapEntry(key, [value])),
      }),
    );
  }

  /// Check if error is network-related
  bool _isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.error is SocketException);
  }

  /// Check if network is available (simplified check)
  bool _isNetworkAvailable() {
    // This is a simplified check. In a real implementation,
    // you might want to use connectivity_plus package
    return true;
  }
}

/// Cache-aware HTTP client mixin
mixin CacheAwareHttpClient {
  /// Get data with cache support
  Future<T?> getCached<T>(
    String endpoint, {
    Duration? ttl,
    bool forceRefresh = false,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final cacheKey = 'GET|$endpoint';
    final cacheManager = CacheManager.instance;

    // Check cache first (unless force refresh)
    if (!forceRefresh) {
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
    }

    return null;
  }

  /// Invalidate cache for specific endpoint
  Future<void> invalidateCache(String endpoint) async {
    final cacheKey = 'GET|$endpoint';
    await CacheManager.instance.remove(cacheKey);
  }

  /// Invalidate cache by pattern
  Future<void> invalidateCachePattern(String pattern) async {
    final cacheManager = CacheManager.instance;

    // This is a simplified implementation
    // In practice, you'd need to iterate through cache keys
    await cacheManager.clear();
  }
}

/// Cache utilities
class CacheUtils {
  /// Warm up cache with essential data
  static Future<void> warmUpCache(List<String> endpoints) async {
    // Implementation would make requests to warm up cache
    // This is a placeholder for the concept
  }

  /// Preload critical data for offline use
  static Future<void> preloadForOffline(List<String> criticalEndpoints) async {
    // Implementation would ensure critical data is cached
    // This is a placeholder for the concept
  }

  /// Get cache health status
  static Future<CacheHealthStatus> getCacheHealth() async {
    final stats = await CacheManager.instance.getStats();

    return CacheHealthStatus(
      isHealthy:
          stats.hitRatio > 0.5 &&
          stats.expiredEntries < stats.totalEntries * 0.3,
      hitRatio: stats.hitRatio,
      totalSize: stats.totalSize,
      recommendations: _generateRecommendations(stats),
    );
  }

  static List<String> _generateRecommendations(CacheStats stats) {
    final recommendations = <String>[];

    if (stats.hitRatio < 0.3) {
      recommendations.add('Consider increasing cache TTL for better hit ratio');
    }

    if (stats.expiredEntries > stats.totalEntries * 0.5) {
      recommendations.add(
        'High number of expired entries, consider cache cleanup',
      );
    }

    if (stats.totalSize > 40 * 1024 * 1024) {
      // 40MB
      recommendations.add(
        'Cache size is large, consider reducing TTL or cache size limit',
      );
    }

    return recommendations;
  }
}

/// Cache health status
class CacheHealthStatus {
  final bool isHealthy;
  final double hitRatio;
  final int totalSize;
  final List<String> recommendations;

  CacheHealthStatus({
    required this.isHealthy,
    required this.hitRatio,
    required this.totalSize,
    required this.recommendations,
  });

  @override
  String toString() =>
      'CacheHealth(healthy: $isHealthy, hitRatio: ${(hitRatio * 100).toStringAsFixed(1)}%, '
      'size: ${totalSize}B, recommendations: ${recommendations.length})';
}
