/// Flutter Traccar API Plugin
/// Flutter Traccar API Plugin
/// 
/// A comprehensive Flutter plugin for integrating with Traccar GPS tracking server.
/// Provides authentication, device management, position tracking, and reporting capabilities.
/// 
/// Features:
/// - Basic authentication with credential caching
/// - Device and position management
/// - Event and command handling
/// - Comprehensive reporting (trips, stops, summary, distance)
/// - Secure credential storage

import 'src/services/traccar_api_service.dart';
import 'src/services/http_service.dart';
import 'src/services/rate_limiter.dart';
import 'src/services/request_batcher.dart';
import 'src/services/cache_manager.dart';
import 'src/models/device.dart' hide Position;
import 'src/models/position.dart';
import 'src/models/event_model.dart';
import 'src/models/command.dart';

import 'src/models/geofence.dart';
import 'src/models/driver.dart';
import 'src/models/maintenance.dart';
import 'src/models/session.dart';
import 'src/models/trips.dart';
import 'src/models/stops_report.dart';
import 'src/models/summary_report.dart';
import 'src/models/report_distance.dart';

// Export all models for easy access
export 'src/models/device.dart' hide Position, Attributes;
export 'src/models/position.dart';
export 'src/models/event_model.dart' hide Attributes;
export 'src/models/command.dart' hide Attributes;

export 'src/models/geofence.dart';
export 'src/models/driver.dart';
export 'src/models/maintenance.dart';
export 'src/models/session.dart' hide Attributes;
export 'src/models/trips.dart';
export 'src/models/stops_report.dart';
export 'src/models/summary_report.dart';
export 'src/models/report_distance.dart';
// New models from OpenAPI schema
export 'src/models/user.dart';
export 'src/models/server.dart';
export 'src/models/group.dart';
export 'src/models/permission.dart';
export 'src/models/command_type.dart';
export 'src/models/notification_type.dart';
export 'src/models/statistics.dart';
export 'src/models/device_accumulators.dart';
export 'src/models/calendar.dart';
export 'src/models/attribute.dart';
// Services
export 'src/services/traccar_api_service.dart';
export 'src/services/auth_manager.dart';
export 'src/services/http_service.dart';
export 'src/services/cache_manager.dart';
export 'src/services/cache_interceptor.dart';
export 'src/services/rate_limiter.dart' hide RateLimitException;
export 'src/services/rate_limit_interceptor.dart';
export 'src/services/request_batcher.dart';
// Exceptions
export 'src/exceptions/traccar_exceptions.dart';
export 'src/utils/error_handler.dart';

/// Main Flutter Traccar API class
/// 
/// This is the primary interface for interacting with Traccar server.
/// It provides authentication, device management, and reporting capabilities.
class FlutterTraccarApi {
  static FlutterTraccarApi? _instance;
  late final TraccarApiService _apiService;
  
  /// Private constructor for singleton pattern
  FlutterTraccarApi._internal({HttpClientConfig? httpConfig}) {
    _apiService = TraccarApiService(httpConfig: httpConfig);
  }
  
  /// Gets the singleton instance of FlutterTraccarApi
  /// 
  /// [httpConfig] - Optional HTTP client configuration for advanced features
  /// like retry logic, timeouts, and logging. Only used on first call.
  factory FlutterTraccarApi({HttpClientConfig? httpConfig}) {
    _instance ??= FlutterTraccarApi._internal(httpConfig: httpConfig);
    return _instance!;
  }
  
  /// Initializes the API service
  /// Should be called before using any other methods
  Future<void> initialize() async {
    await _apiService.initialize();
  }
  
  // Authentication Methods
  
  /// Logs in to Traccar server with username, password, and server URL
  /// 
  /// Returns `true` if login is successful, `false` otherwise.
  /// Credentials are automatically cached on successful login.
  /// 
  /// Example:
  /// ```dart
  /// final api = FlutterTraccarApi();
  /// final success = await api.login(
  ///   username: 'admin',
  ///   password: 'admin',
  ///   serverUrl: 'https://demo.traccar.org',
  /// );
  /// ```
  Future<bool> login({
    required String username,
    required String password,
    required String serverUrl,
  }) async {
    return await _apiService.login(
      username: username,
      password: password,
      serverUrl: serverUrl,
    );
  }
  
  /// Logs out from Traccar server and clears cached credentials
  /// 
  /// Example:
  /// ```dart
  /// await api.logout();
  /// ```
  Future<void> logout() async {
    await _apiService.logout();
  }
  
  /// Checks if user is currently authenticated
  bool get isAuthenticated => _apiService.isAuthenticated;
  
  /// Gets the current username (if authenticated)
  String? get currentUsername => _apiService.currentUsername;
  
  /// Checks if credentials are cached from previous login
  Future<bool> hasCachedCredentials() async {
    return await _apiService.hasCachedCredentials();
  }
  
  /// Refreshes authentication state by validating cached credentials
  Future<bool> refreshAuth() async {
    return await _apiService.refreshAuth();
  }
  
  // Session Management
  
  /// Gets current session information
  Future<Session?> getSession() async {
    return await _apiService.getSession();
  }
  
  // Device Management
  
  /// Gets all devices accessible to the current user
  /// 
  /// Example:
  /// ```dart
  /// final devices = await api.getDevices();
  /// for (final device in devices) {
  ///   print('Device: ${device.name}');
  /// }
  /// ```
  Future<List<Device>> getDevices() async {
    return await _apiService.getDevices();
  }
  
  /// Gets a specific device by ID
  Future<Device?> getDevice(int deviceId) async {
    return await _apiService.getDevice(deviceId);
  }
  
  // Position Management
  
  /// Gets positions for specified devices within a time range
  /// 
  /// Parameters:
  /// - [deviceIds]: List of device IDs (optional, gets all if null)
  /// - [from]: Start time (optional)
  /// - [to]: End time (optional)
  /// 
  /// Example:
  /// ```dart
  /// final positions = await api.getPositions(
  ///   deviceIds: [1, 2, 3],
  ///   from: DateTime.now().subtract(Duration(hours: 24)),
  ///   to: DateTime.now(),
  /// );
  /// ```
  Future<List<Position>> getPositions({
    List<int>? deviceIds,
    DateTime? from,
    DateTime? to,
  }) async {
    return await _apiService.getPositions(
      deviceIds: deviceIds,
      from: from,
      to: to,
    );
  }
  
  // Event Management
  
  /// Gets events for specified devices and types within a time range
  Future<List<Event>> getEvents({
    List<int>? deviceIds,
    DateTime? from,
    DateTime? to,
    List<String>? types,
  }) async {
    return await _apiService.getEvents(
      deviceIds: deviceIds,
      from: from,
      to: to,
      types: types,
    );
  }
  
  // Command Management
  
  /// Sends a command to a device
  Future<bool> sendCommand(Command command) async {
    return await _apiService.sendCommand(command);
  }
  
  // Geofence Management
  
  /// Gets all geofences
  Future<List<Geofence>> getGeofences() async {
    return await _apiService.getGeofences();
  }
  
  // Driver Management
  
  /// Gets all drivers
  Future<List<Driver>> getDrivers() async {
    return await _apiService.getDrivers();
  }
  
  // Maintenance Management
  
  /// Gets all maintenance records
  Future<List<Maintenance>> getMaintenances() async {
    return await _apiService.getMaintenances();
  }
  
  // Report Methods
  
  /// Gets trip reports for specified devices within a time range
  /// 
  /// Example:
  /// ```dart
  /// final trips = await api.getTripReports(
  ///   deviceIds: [1, 2],
  ///   from: DateTime.now().subtract(Duration(days: 7)),
  ///   to: DateTime.now(),
  /// );
  /// ```
  Future<List<Trips>> getTripReports({
    required List<int> deviceIds,
    required DateTime from,
    required DateTime to,
  }) async {
    return await _apiService.getTripReports(
      deviceIds: deviceIds,
      from: from,
      to: to,
    );
  }
  
  /// Gets stops reports for specified devices within a time range
  Future<List<StopsReport>> getStopsReports({
    required List<int> deviceIds,
    required DateTime from,
    required DateTime to,
  }) async {
    return await _apiService.getStopsReports(
      deviceIds: deviceIds,
      from: from,
      to: to,
    );
  }
  
  /// Gets summary reports for specified devices within a time range
  Future<List<ReportSummary>> getSummaryReports({
    required List<int> deviceIds,
    required DateTime from,
    required DateTime to,
  }) async {
    return await _apiService.getSummaryReports(
      deviceIds: deviceIds,
      from: from,
      to: to,
    );
  }
  
  /// Gets distance reports for specified devices within a time range
  Future<List<ReportDistance>> getDistanceReports({
    required List<int> deviceIds,
    required DateTime from,
    required DateTime to,
  }) async {
    return await _apiService.getDistanceReports(
      deviceIds: deviceIds,
      from: from,
      to: to,
    );
  }

  // Rate Limiting Methods

  /// Gets current rate limit status
  RateLimitStatus? getRateLimitStatus() {
    return _apiService.getRateLimitStatus();
  }

  /// Resets the rate limiter
  void resetRateLimit() {
    _apiService.resetRateLimit();
  }

  // Batching Methods

  /// Gets batch statistics
  BatchStats? getBatchingStats() {
    return _apiService.getBatchingStats();
  }

  /// Flushes all pending batches
  Future<void> flushAllBatches() async {
    await _apiService.flushAllBatches();
  }

  /// Gets devices using batched request (if batching is enabled)
  Future<List<Device>> getDevicesBatched() async {
    return await _apiService.getDevicesBatched();
  }

  /// Gets positions using batched request (if batching is enabled)
  Future<List<Position>> getPositionsBatched({
    List<int>? deviceIds,
    DateTime? from,
    DateTime? to,
  }) async {
    return await _apiService.getPositionsBatched(
      deviceIds: deviceIds,
      from: from,
      to: to,
    );
  }

  // Cache Management Methods

  /// Gets cache statistics
  Future<CacheStats> getCacheStats() async {
    return await _apiService.getCacheStats();
  }

  /// Clears all cache
  Future<void> clearCache() async {
    await _apiService.clearCache();
  }

  /// Invalidates device cache
  Future<void> invalidateDeviceCache() async {
    await _apiService.invalidateDeviceCache();
  }

  /// Invalidates position cache
  Future<void> invalidatePositionCache() async {
    await _apiService.invalidatePositionCache();
  }
}
