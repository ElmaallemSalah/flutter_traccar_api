import 'dart:async';
import 'package:dio/dio.dart';

/// Configuration for request batching
class BatchConfig {
  /// Maximum number of requests in a batch
  final int maxBatchSize;
  
  /// Maximum time to wait before sending a batch
  final Duration maxWaitTime;
  
  /// Whether to enable automatic batching
  final bool enableBatching;
  
  /// Endpoints that support batching
  final Set<String> batchableEndpoints;

  const BatchConfig({
    this.maxBatchSize = 10,
    this.maxWaitTime = const Duration(milliseconds: 100),
    this.enableBatching = true,
    this.batchableEndpoints = const {
      '/api/devices',
      '/api/positions',
      '/api/events',
      '/api/geofences',
    },
  });

  /// Default configuration for Traccar API
  static const BatchConfig traccarDefault = BatchConfig(
    maxBatchSize: 5,
    maxWaitTime: Duration(milliseconds: 50),
    enableBatching: true,
    batchableEndpoints: {
      '/api/devices',
      '/api/positions',
      '/api/events',
    },
  );
}

/// Represents a batched request
class BatchedRequest {
  final String method;
  final String path;
  final Map<String, dynamic>? queryParameters;
  final dynamic data;
  final Options? options;
  final Completer<Response> completer;
  final DateTime timestamp;

  BatchedRequest({
    required this.method,
    required this.path,
    this.queryParameters,
    this.data,
    this.options,
    required this.completer,
  }) : timestamp = DateTime.now();

  /// Create a unique key for grouping similar requests
  String get groupKey => '$method:$path';

  /// Check if this request can be batched with another
  bool canBatchWith(BatchedRequest other) {
    return method == other.method &&
           path == other.path &&
           data == null && other.data == null; // Only batch GET requests without body
  }
}

/// Request batcher for optimizing API calls
class RequestBatcher {
  final BatchConfig _config;
  final Dio _dio;
  final Map<String, List<BatchedRequest>> _batches = {};
  final Map<String, Timer> _batchTimers = {};

  RequestBatcher(this._dio, this._config);

  /// Add a request to the batch or execute immediately
  Future<Response<T>> addRequest<T>({
    required String method,
    required String path,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
  }) async {
    if (!_config.enableBatching || !_canBatch(method, path)) {
      return _executeRequest<T>(
        method: method,
        path: path,
        queryParameters: queryParameters,
        data: data,
        options: options,
      );
    }

    final request = BatchedRequest(
      method: method,
      path: path,
      queryParameters: queryParameters,
      data: data,
      options: options,
      completer: Completer<Response>(),
    );

    _addToBatch(request);
    return request.completer.future.then((response) => response as Response<T>);
  }

  /// Check if a request can be batched
  bool _canBatch(String method, String path) {
    return method.toUpperCase() == 'GET' &&
           _config.batchableEndpoints.contains(path);
  }

  /// Add request to appropriate batch
  void _addToBatch(BatchedRequest request) {
    final groupKey = request.groupKey;
    
    _batches.putIfAbsent(groupKey, () => <BatchedRequest>[]);
    _batches[groupKey]!.add(request);

    // Start timer for this batch if not already started
    if (!_batchTimers.containsKey(groupKey)) {
      _batchTimers[groupKey] = Timer(_config.maxWaitTime, () {
        _executeBatch(groupKey);
      });
    }

    // Execute batch if it reaches max size
    if (_batches[groupKey]!.length >= _config.maxBatchSize) {
      _batchTimers[groupKey]?.cancel();
      _batchTimers.remove(groupKey);
      _executeBatch(groupKey);
    }
  }

  /// Execute a batch of requests
  Future<void> _executeBatch(String groupKey) async {
    final requests = _batches.remove(groupKey);
    _batchTimers.remove(groupKey);

    if (requests == null || requests.isEmpty) return;

    try {
      if (requests.length == 1) {
        // Single request - execute normally
        final request = requests.first;
        final response = await _executeRequest(
          method: request.method,
          path: request.path,
          queryParameters: request.queryParameters,
          data: request.data,
          options: request.options,
        );
        request.completer.complete(response);
      } else {
        // Multiple requests - execute in parallel
        await _executeParallelBatch(requests);
      }
    } catch (e) {
      // Complete all requests with the same error
      for (final request in requests) {
        if (!request.completer.isCompleted) {
          request.completer.completeError(e);
        }
      }
    }
  }

  /// Execute multiple requests in parallel
  Future<void> _executeParallelBatch(List<BatchedRequest> requests) async {
    final futures = requests.map((request) async {
      try {
        final response = await _executeRequest(
          method: request.method,
          path: request.path,
          queryParameters: request.queryParameters,
          data: request.data,
          options: request.options,
        );
        request.completer.complete(response);
      } catch (e) {
        request.completer.completeError(e);
      }
    });

    await Future.wait(futures);
  }

  /// Execute a single request
  Future<Response<T>> _executeRequest<T>({
    required String method,
    required String path,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
  }) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return await _dio.get<T>(
          path,
          queryParameters: queryParameters,
          options: options,
        );
      case 'POST':
        return await _dio.post<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      case 'PUT':
        return await _dio.put<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      case 'DELETE':
        return await _dio.delete<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      case 'PATCH':
        return await _dio.patch<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      default:
        throw UnsupportedError('HTTP method $method is not supported');
    }
  }

  /// Get current batch statistics
  BatchStats getStats() {
    int totalPendingRequests = 0;
    int totalBatches = _batches.length;
    
    for (final batch in _batches.values) {
      totalPendingRequests += batch.length;
    }

    return BatchStats(
      pendingBatches: totalBatches,
      pendingRequests: totalPendingRequests,
      activeBatchKeys: _batches.keys.toList(),
    );
  }

  /// Flush all pending batches immediately
  Future<void> flushAll() async {
    final batchKeys = _batches.keys.toList();
    
    for (final key in batchKeys) {
      _batchTimers[key]?.cancel();
      _batchTimers.remove(key);
      await _executeBatch(key);
    }
  }

  /// Clear all pending batches
  void clearAll() {
    for (final timer in _batchTimers.values) {
      timer.cancel();
    }
    _batchTimers.clear();

    for (final requests in _batches.values) {
      for (final request in requests) {
        if (!request.completer.isCompleted) {
          request.completer.completeError(
            Exception('Request batch was cleared'),
          );
        }
      }
    }
    _batches.clear();
  }

  /// Dispose of the batcher
  void dispose() {
    clearAll();
  }
}

/// Batch statistics
class BatchStats {
  final int pendingBatches;
  final int pendingRequests;
  final List<String> activeBatchKeys;

  const BatchStats({
    required this.pendingBatches,
    required this.pendingRequests,
    required this.activeBatchKeys,
  });

  @override
  String toString() {
    return 'BatchStats('
        'batches: $pendingBatches, '
        'requests: $pendingRequests, '
        'keys: $activeBatchKeys'
        ')';
  }
}

/// Mixin for adding batching capabilities to HTTP clients
mixin BatchingCapable {
  RequestBatcher? _batcher;

  /// Initialize batching with configuration
  void initializeBatching(Dio dio, BatchConfig config) {
    _batcher = RequestBatcher(dio, config);
  }

  /// Get the request batcher
  RequestBatcher? get batcher => _batcher;

  /// Make a batched request
  Future<Response<T>> batchedRequest<T>({
    required String method,
    required String path,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
  }) async {
    if (_batcher == null) {
      throw StateError('Batching not initialized. Call initializeBatching first.');
    }

    return _batcher!.addRequest<T>(
      method: method,
      path: path,
      queryParameters: queryParameters,
      data: data,
      options: options,
    );
  }

  /// Flush all pending batches
  Future<void> flushBatches() async {
    await _batcher?.flushAll();
  }

  /// Get batch statistics
  BatchStats? getBatchStats() {
    return _batcher?.getStats();
  }

  /// Dispose batching resources
  void disposeBatching() {
    _batcher?.dispose();
    _batcher = null;
  }
}