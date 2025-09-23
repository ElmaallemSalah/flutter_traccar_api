import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Configuration for cache behavior
class CacheConfig {
  final Duration defaultTtl;
  final int maxCacheSize;
  final bool enableOfflineMode;
  final Map<String, Duration> endpointTtls;

  const CacheConfig({
    this.defaultTtl = const Duration(minutes: 15),
    this.maxCacheSize = 50 * 1024 * 1024, // 50MB
    this.enableOfflineMode = true,
    this.endpointTtls = const {},
  });
}

/// Cache entry with metadata
class CacheEntry {
  final String data;
  final DateTime timestamp;
  final Duration ttl;
  final String etag;
  final Map<String, String> headers;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
    this.etag = '',
    this.headers = const {},
  });

  bool get isExpired => DateTime.now().isAfter(timestamp.add(ttl));

  Map<String, dynamic> toJson() => {
    'data': data,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'ttl': ttl.inMilliseconds,
    'etag': etag,
    'headers': headers,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
    data: json['data'] as String,
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    ttl: Duration(milliseconds: json['ttl'] as int),
    etag: json['etag'] as String? ?? '',
    headers: Map<String, String>.from(json['headers'] as Map? ?? {}),
  );
}

/// Comprehensive cache manager for API responses
class CacheManager {
  static CacheManager? _instance;
  static CacheManager get instance => _instance ??= CacheManager._();
  
  CacheManager._();

  SharedPreferences? _prefs;
  final CacheConfig _config = const CacheConfig();
  final Map<String, CacheEntry> _memoryCache = {};
  
  static const String _cachePrefix = 'traccar_cache_';
  static const String _cacheKeysKey = 'traccar_cache_keys';
  static const String _cacheSizeKey = 'traccar_cache_size';

  /// Initialize the cache manager
  Future<void> initialize([CacheConfig? config]) async {
    _prefs = await SharedPreferences.getInstance();
    await _cleanExpiredEntries();
    await _enforceCacheSize();
  }

  /// Get cached data for a key
  Future<CacheEntry?> get(String key) async {
    // Check memory cache first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      return memoryEntry;
    }

    // Check persistent cache
    final cacheKey = _cachePrefix + key;
    final cachedData = _prefs?.getString(cacheKey);
    
    if (cachedData != null) {
      try {
        final entry = CacheEntry.fromJson(jsonDecode(cachedData));
        
        if (!entry.isExpired) {
          // Update memory cache
          _memoryCache[key] = entry;
          return entry;
        } else {
          // Remove expired entry
          await _removeEntry(key);
        }
      } catch (e) {
        debugPrint('Error parsing cache entry for $key: $e');
        await _removeEntry(key);
      }
    }

    return null;
  }

  /// Store data in cache
  Future<void> put(
    String key,
    String data, {
    Duration? ttl,
    String? etag,
    Map<String, String>? headers,
  }) async {
    final effectiveTtl = ttl ?? _getTtlForKey(key);
    
    final entry = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: effectiveTtl,
      etag: etag ?? '',
      headers: headers ?? {},
    );

    // Store in memory cache
    _memoryCache[key] = entry;

    // Store in persistent cache
    final cacheKey = _cachePrefix + key;
    final serializedEntry = jsonEncode(entry.toJson());
    
    await _prefs?.setString(cacheKey, serializedEntry);
    await _updateCacheKeys(key);
    await _updateCacheSize(serializedEntry.length);
    await _enforceCacheSize();
  }

  /// Check if data exists in cache and is valid
  Future<bool> has(String key) async {
    final entry = await get(key);
    return entry != null;
  }

  /// Remove specific cache entry
  Future<void> remove(String key) async {
    await _removeEntry(key);
  }

  /// Clear all cache
  Future<void> clear() async {
    final keys = await _getCacheKeys();
    
    for (final key in keys) {
      await _prefs?.remove(_cachePrefix + key);
    }
    
    await _prefs?.remove(_cacheKeysKey);
    await _prefs?.remove(_cacheSizeKey);
    _memoryCache.clear();
  }

  /// Get cache statistics
  Future<CacheStats> getStats() async {
    final keys = await _getCacheKeys();
    final size = await _getCacheSize();
    int expiredCount = 0;
    int validCount = 0;

    for (final key in keys) {
      final entry = await get(key);
      if (entry != null) {
        validCount++;
      } else {
        expiredCount++;
      }
    }

    return CacheStats(
      totalEntries: keys.length,
      validEntries: validCount,
      expiredEntries: expiredCount,
      totalSize: size,
      memoryEntries: _memoryCache.length,
    );
  }

  /// Check if offline mode is enabled
  bool get isOfflineModeEnabled => _config.enableOfflineMode;

  /// Get TTL for specific endpoint
  Duration _getTtlForKey(String key) {
    // Check for endpoint-specific TTL
    for (final endpoint in _config.endpointTtls.keys) {
      if (key.contains(endpoint)) {
        return _config.endpointTtls[endpoint]!;
      }
    }
    return _config.defaultTtl;
  }

  /// Update cache keys list
  Future<void> _updateCacheKeys(String key) async {
    final keys = await _getCacheKeys();
    if (!keys.contains(key)) {
      keys.add(key);
      await _prefs?.setStringList(_cacheKeysKey, keys);
    }
  }

  /// Get all cache keys
  Future<List<String>> _getCacheKeys() async {
    return _prefs?.getStringList(_cacheKeysKey) ?? [];
  }

  /// Update cache size
  Future<void> _updateCacheSize(int additionalSize) async {
    final currentSize = await _getCacheSize();
    await _prefs?.setInt(_cacheSizeKey, currentSize + additionalSize);
  }

  /// Get current cache size
  Future<int> _getCacheSize() async {
    return _prefs?.getInt(_cacheSizeKey) ?? 0;
  }

  /// Remove cache entry
  Future<void> _removeEntry(String key) async {
    _memoryCache.remove(key);
    
    final cacheKey = _cachePrefix + key;
    final cachedData = _prefs?.getString(cacheKey);
    
    if (cachedData != null) {
      await _prefs?.remove(cacheKey);
      
      // Update cache size
      final currentSize = await _getCacheSize();
      final newSize = (currentSize - cachedData.length).clamp(0, currentSize);
      await _prefs?.setInt(_cacheSizeKey, newSize);
      
      // Update cache keys
      final keys = await _getCacheKeys();
      keys.remove(key);
      await _prefs?.setStringList(_cacheKeysKey, keys);
    }
  }

  /// Clean expired entries
  Future<void> _cleanExpiredEntries() async {
    final keys = await _getCacheKeys();
    final expiredKeys = <String>[];

    for (final key in keys) {
      final cacheKey = _cachePrefix + key;
      final cachedData = _prefs?.getString(cacheKey);
      
      if (cachedData != null) {
        try {
          final entry = CacheEntry.fromJson(jsonDecode(cachedData));
          if (entry.isExpired) {
            expiredKeys.add(key);
          }
        } catch (e) {
          expiredKeys.add(key);
        }
      }
    }

    for (final key in expiredKeys) {
      await _removeEntry(key);
    }
  }

  /// Enforce cache size limits
  Future<void> _enforceCacheSize() async {
    final currentSize = await _getCacheSize();
    
    if (currentSize > _config.maxCacheSize) {
      final keys = await _getCacheKeys();
      
      // Sort by timestamp (oldest first)
      final entries = <MapEntry<String, DateTime>>[];
      
      for (final key in keys) {
        final cacheKey = _cachePrefix + key;
        final cachedData = _prefs?.getString(cacheKey);
        
        if (cachedData != null) {
          try {
            final entry = CacheEntry.fromJson(jsonDecode(cachedData));
            entries.add(MapEntry(key, entry.timestamp));
          } catch (e) {
            // Remove corrupted entries
            await _removeEntry(key);
          }
        }
      }
      
      entries.sort((a, b) => a.value.compareTo(b.value));
      
      // Remove oldest entries until under size limit
      int removedSize = 0;
      for (final entry in entries) {
        if (currentSize - removedSize <= _config.maxCacheSize) break;
        
        final cacheKey = _cachePrefix + entry.key;
        final cachedData = _prefs?.getString(cacheKey);
        if (cachedData != null) {
          removedSize += cachedData.length;
          await _removeEntry(entry.key);
        }
      }
    }
  }
}

/// Cache statistics
class CacheStats {
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;
  final int totalSize;
  final int memoryEntries;

  CacheStats({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
    required this.totalSize,
    required this.memoryEntries,
  });

  double get hitRatio => totalEntries > 0 ? validEntries / totalEntries : 0.0;
  
  String get formattedSize {
    if (totalSize < 1024) return '${totalSize}B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(1)}KB';
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  String toString() => 'CacheStats(entries: $totalEntries, valid: $validEntries, '
      'expired: $expiredEntries, size: $formattedSize, memory: $memoryEntries, '
      'hit ratio: ${(hitRatio * 100).toStringAsFixed(1)}%)';
}