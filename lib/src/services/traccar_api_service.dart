import '../models/device.dart' hide Position;
import '../models/position.dart';
import '../models/event_model.dart';
import '../models/command.dart';

import '../models/geofence.dart';
import '../models/driver.dart';
import '../models/maintenance.dart';
import '../models/session.dart';
import '../models/trips.dart';
import '../models/stops_report.dart';
import '../models/summary_report.dart';
import '../models/report_distance.dart';
import 'auth_manager.dart';
import 'http_service.dart';
import 'cache_manager.dart';
import 'rate_limiter.dart';
import 'request_batcher.dart';
import 'websocket_service.dart';

/// Main Traccar API service that provides all API endpoints
/// with authentication and caching support
class TraccarApiService {
  final AuthManager _authManager;
  late final HttpService _httpService;
  late final WebSocketService _webSocketService;

  /// Creates an instance of TraccarApiService
  TraccarApiService({
    AuthManager? authManager,
    HttpClientConfig? httpConfig,
    WebSocketConfig? webSocketConfig,
  }) : _authManager = authManager ?? AuthManager(httpConfig: httpConfig) {
    _httpService = _authManager.httpService;
    _webSocketService = WebSocketService(
      authManager: _authManager,
      config: webSocketConfig,
    );
  }

  /// Initializes the service by loading cached credentials
  Future<void> initialize() async {
    await _authManager.initialize();
  }

  // Authentication Methods

  /// Logs in with username, password, and server URL
  /// Caches credentials on successful login
  Future<bool> login({
    required String username,
    required String password,
    required String serverUrl,
  }) async {
    return await _authManager.login(
      username: username,
      password: password,
      baseUrl: serverUrl,
    );
  }

  /// Logs out and clears cached credentials
  Future<void> logout() async {
    await _authManager.logout();
  }

  /// Checks if user is currently authenticated
  bool get isAuthenticated => _authManager.isAuthenticated;

  /// Gets current username
  String? get currentUsername => _authManager.currentUsername;

  /// Checks if credentials are cached
  Future<bool> hasCachedCredentials() async {
    return await _authManager.hasCachedCredentials();
  }

  /// Refreshes authentication state
  Future<bool> refreshAuth() async {
    return await _authManager.refreshAuth();
  }

  // Session Management

  /// Gets current session information
  Future<Session?> getSession() async {
    try {
      final response = await _httpService.get('/api/session');
      if (response.statusCode == 200 && response.data != null) {
        return Session.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get session: $e');
    }
  }

  // Device Management

  /// Gets all devices
  Future<List<Device>> getDevices() async {
    try {
      final response = await _httpService.get('/api/devices');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => Device.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get devices: $e');
    }
  }

  /// Gets a specific device by ID
  Future<Device?> getDevice(int deviceId) async {
    try {
      final response = await _httpService.get('/api/devices/$deviceId');
      if (response.statusCode == 200 && response.data != null) {
        return Device.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get device: $e');
    }
  }

  // Position Management

  /// Gets positions for devices
  Future<List<Position>> getPositions({
    List<int>? deviceIds,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (deviceIds != null && deviceIds.isNotEmpty) {
        queryParams['deviceId'] = deviceIds;
      }
      if (from != null) {
        queryParams['from'] = from.toIso8601String();
      }
      if (to != null) {
        queryParams['to'] = to.toIso8601String();
      }

      final response = await _httpService.get(
        '/api/positions',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => Position.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get positions: $e');
    }
  }

  // Event Management

  /// Gets events
  Future<List<Event>> getEvents({
    List<int>? deviceIds,
    DateTime? from,
    DateTime? to,
    List<String>? types,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (deviceIds != null && deviceIds.isNotEmpty) {
        queryParams['deviceId'] = deviceIds;
      }
      if (from != null) {
        queryParams['from'] = from.toIso8601String();
      }
      if (to != null) {
        queryParams['to'] = to.toIso8601String();
      }
      if (types != null && types.isNotEmpty) {
        queryParams['type'] = types;
      }

      final response = await _httpService.get(
        '/api/events',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => Event.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  // Command Management

  /// Sends a command to a device
  Future<bool> sendCommand(Command command) async {
    try {
      final response = await _httpService.post(
        '/api/commands/send',
        data: command.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to send command: $e');
    }
  }

  // Geofence Management

  /// Gets all geofences
  Future<List<Geofence>> getGeofences() async {
    try {
      final response = await _httpService.get('/api/geofences');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => Geofence.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get geofences: $e');
    }
  }

  // Driver Management

  /// Gets all drivers
  Future<List<Driver>> getDrivers() async {
    try {
      final response = await _httpService.get('/api/drivers');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => Driver.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get drivers: $e');
    }
  }

  // Maintenance Management

  /// Gets all maintenance records
  Future<List<Maintenance>> getMaintenances() async {
    try {
      final response = await _httpService.get('/api/maintenance');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => Maintenance.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get maintenance records: $e');
    }
  }

  // Report Methods

  /// Gets trip reports
  Future<List<Trips>> getTripReports({
    required List<int> deviceIds,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final queryParams = {
        'deviceId': deviceIds,
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      };

      final response = await _httpService.get(
        '/api/reports/trips',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => Trips.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get trip reports: $e');
    }
  }

  /// Gets stops reports
  Future<List<StopsReport>> getStopsReports({
    required List<int> deviceIds,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final queryParams = {
        'deviceId': deviceIds,
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      };

      final response = await _httpService.get(
        '/api/reports/stops',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => StopsReport.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get stops reports: $e');
    }
  }

  /// Gets summary reports
  Future<List<ReportSummary>> getSummaryReports({
    required List<int> deviceIds,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final queryParams = {
        'deviceId': deviceIds,
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      };

      final response = await _httpService.get(
        '/api/reports/summary',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => ReportSummary.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get summary reports: $e');
    }
  }

  /// Gets distance reports
  Future<List<ReportDistance>> getDistanceReports({
    required List<int> deviceIds,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final queryParams = {
        'deviceId': deviceIds,
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      };

      final response = await _httpService.get(
        '/api/reports/route',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => ReportDistance.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get distance reports: $e');
    }
  }

  // Cache Management Methods

  /// Get cache manager instance
  CacheManager get cacheManager => _httpService.cacheManager;

  /// Clear all cached API responses
  Future<void> clearCache() async {
    await _httpService.clearCache();
  }

  /// Invalidate cache for specific endpoint
  Future<void> invalidateCache(String endpoint) async {
    await _httpService.invalidateCache(endpoint);
  }

  /// Get cache statistics
  Future<CacheStats> getCacheStats() async {
    return await _httpService.getCacheStats();
  }

  /// Invalidate device-related cache
  Future<void> invalidateDeviceCache() async {
    await invalidateCache('/api/devices');
  }

  /// Invalidate position-related cache
  Future<void> invalidatePositionCache() async {
    await invalidateCache('/api/positions');
  }

  /// Invalidate geofence-related cache
  Future<void> invalidateGeofenceCache() async {
    await invalidateCache('/api/geofences');
  }

  // Rate Limiting Methods

  /// Get current rate limit status
  RateLimitStatus? getRateLimitStatus() {
    return _httpService.getRateLimitStatus();
  }

  /// Reset rate limiter
  void resetRateLimit() {
    _httpService.resetRateLimit();
  }

  // Batching Methods

  /// Get batch statistics
  BatchStats? getBatchingStats() {
    return _httpService.getBatchingStats();
  }

  /// Flush all pending batches
  Future<void> flushAllBatches() async {
    await _httpService.flushAllBatches();
  }

  /// Get devices using batched request (if batching is enabled)
  Future<List<Device>> getDevicesBatched() async {
    try {
      final response = await _httpService.batchedGet('/api/devices');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => Device.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get devices: $e');
    }
  }

  /// Get positions using batched request (if batching is enabled)
  Future<List<Position>> getPositionsBatched({
    List<int>? deviceIds,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (deviceIds != null && deviceIds.isNotEmpty) {
        queryParams['deviceId'] = deviceIds;
      }
      if (from != null) {
        queryParams['from'] = from.toIso8601String();
      }
      if (to != null) {
        queryParams['to'] = to.toIso8601String();
      }

      final response = await _httpService.batchedGet(
        '/api/positions',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => Position.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get positions: $e');
    }
  }

  // WebSocket Real-time Methods

  /// Connects to WebSocket for real-time updates
  /// Returns true if connection is successful
  Future<bool> connectWebSocket() async {
    return await _webSocketService.connect();
  }

  /// Disconnects from WebSocket
  Future<void> disconnectWebSocket() async {
    await _webSocketService.disconnect();
  }

  /// Gets WebSocket connection status
  bool get isWebSocketConnected => _webSocketService.isConnected;

  /// Stream of real-time device updates
  Stream<List<Device>> get deviceUpdatesStream => _webSocketService.devicesStream;

  /// Stream of real-time position updates
  Stream<List<Position>> get positionUpdatesStream => _webSocketService.positionsStream;

  /// Stream of real-time event updates
  Stream<List<Event>> get eventUpdatesStream => _webSocketService.eventsStream;

  /// Stream of WebSocket connection status changes
  Stream<WebSocketStatus> get webSocketStatusStream => _webSocketService.statusStream;

  /// Disposes of all resources including WebSocket connections
  void dispose() {
    _webSocketService.dispose();
  }
}