import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/device.dart' hide Position;
import '../models/position.dart';
import '../models/event_model.dart';
import 'auth_manager.dart';

/// WebSocket connection status enumeration
enum WebSocketStatus {
  /// WebSocket is disconnected
  disconnected,

  /// WebSocket is connecting
  connecting,

  /// WebSocket is connected and ready
  connected,

  /// WebSocket connection failed
  error,

  /// WebSocket is reconnecting
  reconnecting,
}

/// Configuration for WebSocket service
class WebSocketConfig {
  /// Maximum number of reconnection attempts
  final int maxReconnectAttempts;

  /// Delay between reconnection attempts
  final Duration reconnectDelay;

  /// Interval for sending heartbeat messages
  final Duration heartbeatInterval;

  /// Whether to automatically reconnect on connection loss
  final bool autoReconnect;

  /// Creates a WebSocket configuration
  const WebSocketConfig({
    this.maxReconnectAttempts = 5,
    this.reconnectDelay = const Duration(seconds: 5),
    this.heartbeatInterval = const Duration(seconds: 30),
    this.autoReconnect = true,
  });
}

/// WebSocket service for real-time communication with Traccar server
///
/// Provides real-time updates for devices, positions, and events through
/// WebSocket connection with automatic reconnection and session management.
class WebSocketService {
  final AuthManager _authManager;
  final WebSocketConfig _config;

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  bool _isConnected = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;

  // Stream controllers for different data types
  late final StreamController<List<Device>> _devicesController;
  late final StreamController<List<Position>> _positionsController;
  late final StreamController<List<Event>> _eventsController;
  late final StreamController<WebSocketStatus> _statusController;

  /// Stream of device updates
  Stream<List<Device>> get devicesStream => _devicesController.stream;

  /// Stream of position updates
  Stream<List<Position>> get positionsStream => _positionsController.stream;

  /// Stream of event updates
  Stream<List<Event>> get eventsStream => _eventsController.stream;

  /// Stream of connection status changes
  Stream<WebSocketStatus> get statusStream => _statusController.stream;

  /// Current connection status
  bool get isConnected => _isConnected;

  /// Creates a WebSocket service instance
  ///
  /// [authManager] - Authentication manager for session handling
  /// [config] - WebSocket configuration options
  WebSocketService({required AuthManager authManager, WebSocketConfig? config})
    : _authManager = authManager,
      _config = config ?? const WebSocketConfig() {
    _initializeControllers();
  }

  /// Initializes stream controllers
  void _initializeControllers() {
    _devicesController = StreamController<List<Device>>.broadcast();
    _positionsController = StreamController<List<Position>>.broadcast();
    _eventsController = StreamController<List<Event>>.broadcast();
    _statusController = StreamController<WebSocketStatus>.broadcast();
  }

  /// Connects to the Traccar WebSocket server
  ///
  /// Establishes a session first, then connects to WebSocket with session cookie.
  /// Returns true if connection is successful, false otherwise.
  Future<bool> connect() async {
    if (_channel != null) {
      await disconnect();
    }

    if (!_authManager.isAuthenticated) {
      log('WebSocket: Not authenticated, cannot connect');
      _updateStatus(WebSocketStatus.error);
      return false;
    }

    _updateStatus(WebSocketStatus.connecting);

    try {
      // Get session cookie for WebSocket authentication
      final sessionCookie = await _establishSession();
      if (sessionCookie == null) {
        log('WebSocket: Failed to establish session');
        _updateStatus(WebSocketStatus.error);
        return false;
      }

      // Connect to WebSocket with session cookie
      final success = await _connectWebSocket(sessionCookie);
      if (success) {
        _isConnected = true;
        _reconnectAttempts = 0;
        _updateStatus(WebSocketStatus.connected);
        _startHeartbeat();
        log('WebSocket: Connected successfully');
        return true;
      } else {
        _updateStatus(WebSocketStatus.error);
        return false;
      }
    } catch (e) {
      log('WebSocket: Connection failed: $e');
      _updateStatus(WebSocketStatus.error);
      _scheduleReconnect();
      return false;
    }
  }

  /// Establishes a session and returns the session cookie
  Future<String?> _establishSession() async {
    try {
      // Get current credentials from auth manager
      final username = _authManager.currentUsername;
      final password = _authManager.currentPassword;

      if (username == null || password == null) {
        log('WebSocket: No credentials available for session establishment');
        return null;
      }

      // Use POST request like login to establish session
      final response = await _authManager.httpService.post(
        '/api/session',
        data: {'email': username, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        // Extract session cookie from response headers
        final cookies = response.headers['set-cookie'];
        if (cookies != null && cookies.isNotEmpty) {
          final sessionCookie = cookies.first.split(';').first;
          log('WebSocket: Session established');
          return sessionCookie;
        }
      }

      log('WebSocket: Failed to get session cookie');
      return null;
    } catch (e) {
      log('WebSocket: Session establishment failed: $e');
      return null;
    }
  }

  /// Connects to WebSocket with the provided session cookie
  Future<bool> _connectWebSocket(String sessionCookie) async {
    try {
      final baseUrl = _authManager.baseUrl;
      if (baseUrl == null) {
        log('WebSocket: No base URL configured');
        return false;
      }

      // Convert HTTP URL to WebSocket URL
      final wsUrl = _buildWebSocketUrl(baseUrl);
      log('WebSocket: Connecting to $wsUrl');

      _channel = IOWebSocketChannel.connect(
        wsUrl,
        headers: {'Cookie': sessionCookie},
      );

      await _channel!.ready;

      // Listen to messages
      _channel!.stream.listen(_onMessage, onError: _onError, onDone: _onDone);

      return true;
    } catch (e) {
      log('WebSocket: Connection failed: $e');
      return false;
    }
  }

  /// Builds WebSocket URL from HTTP base URL
  Uri _buildWebSocketUrl(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';

    // Only include port if it's not the default port
    final isDefaultPort =
        (uri.scheme == 'https' && uri.port == 443) ||
        (uri.scheme == 'http' && uri.port == 80);

    return Uri(
      scheme: scheme,
      host: uri.host,
      port: isDefaultPort ? null : uri.port,
      path: '/api/socket',
    );
  }

  /// Handles incoming WebSocket messages
  void _onMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);

      // Handle different message types from Traccar
      if (data.containsKey('devices')) {
        _handleDevicesUpdate(data['devices']);
      } else if (data.containsKey('device')) {
        _handleSingleDeviceUpdate(data['device']);
      } else if (data.containsKey('positions')) {
        _handlePositionsUpdate(data['positions']);
      } else if (data.containsKey('events')) {
        _handleEventsUpdate(data['events']);
      } else {
        log('WebSocket: Unknown message format: ${data.keys.toList()}');
      }
    } catch (e) {
      log('WebSocket: Error parsing message: $e');
    }
  }

  /// Handles device updates
  void _handleDevicesUpdate(List<dynamic> devicesData) {
    try {
      final devices = devicesData
          .map((device) => Device.fromJson(device))
          .toList();
      _devicesController.add(devices);
      //  log('WebSocket: Received ${devices.length} device updates');
    } catch (e) {
      log('WebSocket: Error parsing devices: $e');
    }
  }

  /// Handles single device update
  void _handleSingleDeviceUpdate(Map<String, dynamic> deviceData) {
    try {
      final device = Device.fromJson(deviceData);
      _devicesController.add([device]);
      log('WebSocket: Received single device update: ${device.name}');
    } catch (e) {
      log('WebSocket: Error parsing single device: $e');
    }
  }

  /// Handles position updates
  void _handlePositionsUpdate(List<dynamic> positionsData) {
    try {
      final positions = positionsData
          .map((position) => Position.fromJson(position))
          .toList();
      _positionsController.add(positions);
      log('WebSocket: Received ${positions.length} position updates');
    } catch (e) {
      log('WebSocket: Error parsing positions: $e');
    }
  }

  /// Handles event updates
  void _handleEventsUpdate(List<dynamic> eventsData) {
    try {
      final events = eventsData.map((event) => Event.fromJson(event)).toList();
      _eventsController.add(events);
      log('WebSocket: Received ${events.length} event updates');
    } catch (e) {
      log('WebSocket: Error parsing events: $e');
    }
  }

  /// Handles WebSocket errors
  void _onError(error) {
    log('WebSocket: Error occurred: $error');
    _isConnected = false;
    _updateStatus(WebSocketStatus.error);
    _scheduleReconnect();
  }

  /// Handles WebSocket connection closure
  void _onDone() {
    log('WebSocket: Connection closed');
    _isConnected = false;
    _updateStatus(WebSocketStatus.disconnected);
    _stopHeartbeat();

    if (_shouldReconnect && _config.autoReconnect) {
      _scheduleReconnect();
    }
  }

  /// Starts the heartbeat timer
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_config.heartbeatInterval, (timer) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add('ping');
          log('WebSocket: Heartbeat sent');
        } catch (e) {
          log('WebSocket: Heartbeat failed: $e');
        }
      }
    });
  }

  /// Stops the heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Schedules a reconnection attempt
  void _scheduleReconnect() {
    if (!_config.autoReconnect ||
        _reconnectAttempts >= _config.maxReconnectAttempts) {
      log(
        'WebSocket: Max reconnect attempts reached or auto-reconnect disabled',
      );
      return;
    }

    _reconnectAttempts++;
    _reconnectTimer?.cancel();
    _updateStatus(WebSocketStatus.reconnecting);

    log(
      'WebSocket: Scheduling reconnect attempt $_reconnectAttempts '
      'in ${_config.reconnectDelay.inSeconds} seconds',
    );

    _reconnectTimer = Timer(_config.reconnectDelay, () {
      if (_shouldReconnect) {
        connect();
      }
    });
  }

  /// Updates the connection status
  void _updateStatus(WebSocketStatus status) {
    _statusController.add(status);
  }

  /// Disconnects from the WebSocket server
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _stopHeartbeat();

    if (_channel != null) {
      try {
        await _channel!.sink.close(status.normalClosure);
      } catch (e) {
        log('WebSocket: Error during disconnect: $e');
      }
      _channel = null;
    }

    _isConnected = false;
    _updateStatus(WebSocketStatus.disconnected);
    log('WebSocket: Disconnected');
  }

  /// Disposes of the WebSocket service and closes all streams
  void dispose() {
    disconnect();
    _devicesController.close();
    _positionsController.close();
    _eventsController.close();
    _statusController.close();
  }

  // Test helper methods (visible for testing)

  /// Simulates receiving a message (for testing)
  void onMessage(String message) {
    _onMessage(message);
  }

  /// Gets the current configuration (for testing)
  WebSocketConfig get config => _config;

  /// Builds WebSocket URL (for testing)
  String buildWebSocketUrl(String baseUrl) =>
      _buildWebSocketUrl(baseUrl).toString();

  /// Updates status (for testing)
  void updateStatus(WebSocketStatus status) => _updateStatus(status);
}
