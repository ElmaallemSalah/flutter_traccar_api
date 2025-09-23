import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_traccar_api/src/services/websocket_service.dart';
import 'package:flutter_traccar_api/src/services/auth_manager.dart';
import 'package:flutter_traccar_api/src/services/http_service.dart';
import 'package:flutter_traccar_api/src/models/device.dart';
import 'package:flutter_traccar_api/src/models/position.dart' as traccar;
import 'package:flutter_traccar_api/src/models/event_model.dart';
import 'package:dio/dio.dart';

import 'websocket_service_test.mocks.dart';

@GenerateMocks([AuthManager, HttpService, WebSocketChannel])
void main() {
  group('WebSocketService', () {
    late WebSocketService webSocketService;
    late MockAuthManager mockAuthManager;
    late MockHttpService mockHttpService;
    late StreamController<dynamic> mockStreamController;

    setUp(() {
      mockAuthManager = MockAuthManager();
      mockHttpService = MockHttpService();
      mockStreamController = StreamController<dynamic>.broadcast();

      // Setup auth manager mocks
      when(mockAuthManager.httpService).thenReturn(mockHttpService);
      when(mockAuthManager.isAuthenticated).thenReturn(true);
      when(mockAuthManager.currentUsername).thenReturn('test@example.com');
      when(mockAuthManager.baseUrl).thenReturn('http://localhost:8082');

      webSocketService = WebSocketService(
        authManager: mockAuthManager,
        config: const WebSocketConfig(
          maxReconnectAttempts: 3,
          reconnectDelay: Duration(milliseconds: 100),
          heartbeatInterval: Duration(milliseconds: 500),
          autoReconnect: true,
        ),
      );
    });

    tearDown(() {
      mockStreamController.close();
      webSocketService.dispose();
    });

    group('Connection Management', () {
      test('should not connect when not authenticated', () async {
        when(mockAuthManager.isAuthenticated).thenReturn(false);

        final result = await webSocketService.connect();

        expect(result, false);
        expect(webSocketService.isConnected, false);
      });

      test('should establish session and connect successfully', () async {
        // Mock session establishment
        when(mockHttpService.get('/api/session')).thenAnswer(
          (_) async => Response(
            statusCode: 200,
            data: {'id': 1, 'name': 'test'},
            requestOptions: RequestOptions(path: '/api/session'),
            headers: Headers.fromMap({
              'set-cookie': ['JSESSIONID=ABC123; Path=/'],
            }),
          ),
        );

        final result = await webSocketService.connect();

        expect(result, true);
        verify(mockHttpService.get('/api/session')).called(1);
      });

      test('should fail to connect when session establishment fails', () async {
        when(mockHttpService.get('/api/session')).thenAnswer(
          (_) async => Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/api/session'),
          ),
        );

        final result = await webSocketService.connect();

        expect(result, false);
        expect(webSocketService.isConnected, false);
      });

      test('should disconnect properly', () async {
        await webSocketService.disconnect();

        expect(webSocketService.isConnected, false);
      });
    });

    group('Message Handling', () {
      test('should handle device updates correctly', () async {
        final deviceData = [
          {
            'id': 1,
            'name': 'Test Device',
            'uniqueId': 'test123',
            'status': 'online',
            'lastUpdate': '2024-01-01T00:00:00Z',
          },
        ];

        final message = jsonEncode({'devices': deviceData});
        final receivedDevices = <List<Device>>[];

        webSocketService.devicesStream.listen((devices) {
          receivedDevices.add(devices);
        });

        // Simulate message reception
        webSocketService.onMessage(message);

        await Future.delayed(const Duration(milliseconds: 10));

        expect(receivedDevices.length, 1);
        expect(receivedDevices.first.length, 1);
        expect(receivedDevices.first.first.name, 'Test Device');
      });

      test('should handle position updates correctly', () async {
        final positionData = [
          {
            'id': 1,
            'deviceId': 1,
            'latitude': 40.7128,
            'longitude': -74.0060,
            'speed': 50.0,
            'course': 180.0,
            'deviceTime': '2024-01-01T00:00:00Z',
            'serverTime': '2024-01-01T00:00:00Z',
            'fixTime': '2024-01-01T00:00:00Z',
            'valid': true,
            'attributes': {},
          },
        ];

        final message = jsonEncode({'positions': positionData});
        final receivedPositions = <List<traccar.Position>>[];

        webSocketService.positionsStream.listen((positions) {
          receivedPositions.add(positions);
        });

        // Simulate message reception
        webSocketService.onMessage(message);

        await Future.delayed(const Duration(milliseconds: 10));

        expect(receivedPositions.length, 1);
        expect(receivedPositions.first.length, 1);
        expect(receivedPositions.first.first.latitude, 40.7128);
        expect(receivedPositions.first.first.longitude, -74.0060);
      });

      test('should handle event updates correctly', () async {
        final eventData = [
          {
            'id': 1,
            'deviceId': 1,
            'type': 'deviceOnline',
            'eventTime': '2024-01-01T00:00:00Z',
            'attributes': {},
          },
        ];

        final message = jsonEncode({'events': eventData});
        final receivedEvents = <List<Event>>[];

        webSocketService.eventsStream.listen((events) {
          receivedEvents.add(events);
        });

        // Simulate message reception
        webSocketService.onMessage(message);

        await Future.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(receivedEvents.first.length, 1);
        expect(receivedEvents.first.first.type, 'deviceOnline');
      });

      test('should handle single device update correctly', () async {
        final deviceData = {
          'id': 1,
          'name': 'Single Device',
          'uniqueId': 'single123',
          'status': 'online',
          'lastUpdate': '2024-01-01T00:00:00Z',
        };

        final message = jsonEncode({'device': deviceData});
        final receivedDevices = <List<Device>>[];

        webSocketService.devicesStream.listen((devices) {
          receivedDevices.add(devices);
        });

        // Simulate message reception
        webSocketService.onMessage(message);

        await Future.delayed(const Duration(milliseconds: 10));

        expect(receivedDevices.length, 1);
        expect(receivedDevices.first.length, 1);
        expect(receivedDevices.first.first.name, 'Single Device');
      });

      test('should handle malformed messages gracefully', () async {
        final malformedMessage = 'invalid json';

        // Should not throw an exception
        expect(
          () => webSocketService.onMessage(malformedMessage),
          returnsNormally,
        );
      });

      test('should handle unknown message types gracefully', () async {
        final unknownMessage = jsonEncode({'unknown': 'data'});

        // Should not throw an exception
        expect(
          () => webSocketService.onMessage(unknownMessage),
          returnsNormally,
        );
      });
    });

    group('Status Management', () {
      test('should emit status changes correctly', () async {
        final statusChanges = <WebSocketStatus>[];

        webSocketService.statusStream.listen((status) {
          statusChanges.add(status);
        });

        // Simulate status changes
        webSocketService.updateStatus(WebSocketStatus.connecting);
        webSocketService.updateStatus(WebSocketStatus.connected);
        webSocketService.updateStatus(WebSocketStatus.disconnected);

        await Future.delayed(const Duration(milliseconds: 10));

        expect(statusChanges.length, 3);
        expect(statusChanges[0], WebSocketStatus.connecting);
        expect(statusChanges[1], WebSocketStatus.connected);
        expect(statusChanges[2], WebSocketStatus.disconnected);
      });
    });

    group('Configuration', () {
      test('should use custom configuration', () {
        final customConfig = WebSocketConfig(
          maxReconnectAttempts: 10,
          reconnectDelay: Duration(seconds: 2),
          heartbeatInterval: Duration(minutes: 1),
          autoReconnect: false,
        );

        final customService = WebSocketService(
          authManager: mockAuthManager,
          config: customConfig,
        );

        expect(customService.config.maxReconnectAttempts, 10);
        expect(customService.config.reconnectDelay, Duration(seconds: 2));
        expect(customService.config.heartbeatInterval, Duration(minutes: 1));
        expect(customService.config.autoReconnect, false);

        customService.dispose();
      });

      test('should use default configuration when none provided', () {
        final defaultService = WebSocketService(authManager: mockAuthManager);

        expect(defaultService.config.maxReconnectAttempts, 5);
        expect(defaultService.config.reconnectDelay, Duration(seconds: 5));
        expect(defaultService.config.heartbeatInterval, Duration(seconds: 30));
        expect(defaultService.config.autoReconnect, true);

        defaultService.dispose();
      });
    });

    group('URL Building', () {
      test('should build correct WebSocket URL from HTTP URL', () {
        final httpUrl = 'http://localhost:8082';
        final expectedWsUrl = 'ws://localhost:8082/api/socket';

        final wsUrl = webSocketService.buildWebSocketUrl(httpUrl);

        expect(wsUrl.toString(), expectedWsUrl);
      });

      test('should build correct WebSocket URL from HTTPS URL', () {
        final httpsUrl = 'https://demo.traccar.org';
        final expectedWssUrl = 'wss://demo.traccar.org/api/socket';

        final wsUrl = webSocketService.buildWebSocketUrl(httpsUrl);

        expect(wsUrl.toString(), expectedWssUrl);
      });

      test('should handle URLs with custom ports', () {
        final httpUrl = 'http://localhost:8080';
        final expectedWsUrl = 'ws://localhost:8080/api/socket';

        final wsUrl = webSocketService.buildWebSocketUrl(httpUrl);

        expect(wsUrl.toString(), expectedWsUrl);
      });
    });
  });
}
