import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:flutter_traccar_api/src/services/traccar_api_service.dart';
import 'package:flutter_traccar_api/src/models/device.dart' hide Position;
import 'package:flutter_traccar_api/src/models/position.dart';
import 'package:flutter_traccar_api/src/models/session.dart';
import 'package:flutter_traccar_api/src/models/event_model.dart';
import 'package:flutter_traccar_api/src/models/trips.dart';
import 'package:flutter_traccar_api/src/models/stops_report.dart';
import 'package:flutter_traccar_api/src/models/summary_report.dart';
import 'package:flutter_traccar_api/src/models/report_distance.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('TraccarApiService Tests', () {
    late MockAuthManager mockAuthManager;
    late MockHttpService mockHttpService;
    late TraccarApiService apiService;

    setUp(() {
      mockAuthManager = MockAuthManager();
      mockHttpService = MockHttpService();
      
      // Setup the auth manager to return the mock HTTP service
      when(mockAuthManager.httpService).thenReturn(mockHttpService);
      
      apiService = TraccarApiService(authManager: mockAuthManager);
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Arrange
        when(mockAuthManager.initialize()).thenAnswer((_) async {});

        // Act
        await apiService.initialize();

        // Assert
        verify(mockAuthManager.initialize());
      });
    });

    group('Authentication', () {
      test('should login successfully', () async {
        // Arrange
        when(mockAuthManager.login(
          username: anyNamed('username'),
          password: anyNamed('password'),
          baseUrl: anyNamed('baseUrl'),
        )).thenAnswer((_) async => true);

        // Act
        final result = await apiService.login(
          username: 'testuser',
          password: 'testpass',
          serverUrl: 'https://demo.traccar.org',
        );

        // Assert
        expect(result, true);
        verify(mockAuthManager.login(
          username: 'testuser',
          password: 'testpass',
          baseUrl: 'https://demo.traccar.org',
        ));
      });

      test('should logout successfully', () async {
        // Arrange
        when(mockAuthManager.logout()).thenAnswer((_) async {});

        // Act
        await apiService.logout();

        // Assert
        verify(mockAuthManager.logout());
      });

      test('should check authentication status', () {
        // Arrange
        when(mockAuthManager.isAuthenticated).thenReturn(true);

        // Act
        final result = apiService.isAuthenticated;

        // Assert
        expect(result, true);
        verify(mockAuthManager.isAuthenticated);
      });

      test('should get current username', () {
        // Arrange
        when(mockAuthManager.currentUsername).thenReturn('testuser');

        // Act
        final result = apiService.currentUsername;

        // Assert
        expect(result, 'testuser');
        verify(mockAuthManager.currentUsername);
      });

      test('should check cached credentials', () async {
        // Arrange
        when(mockAuthManager.hasCachedCredentials())
            .thenAnswer((_) async => true);

        // Act
        final result = await apiService.hasCachedCredentials();

        // Assert
        expect(result, true);
        verify(mockAuthManager.hasCachedCredentials());
      });

      test('should refresh authentication', () async {
        // Arrange
        when(mockAuthManager.refreshAuth()).thenAnswer((_) async => true);

        // Act
        final result = await apiService.refreshAuth();

        // Assert
        expect(result, true);
        verify(mockAuthManager.refreshAuth());
      });
    });

    group('Session Management', () {
      test('should get session successfully', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: TestHelpers.sampleSessionData,
          statusCode: 200,
        );
        when(mockHttpService.get('/api/session'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.getSession();

        // Assert
        expect(result, isA<Session>());
        expect(result?.name, 'Test User');
        verify(mockHttpService.get('/api/session'));
      });

      test('should handle session error', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: null,
          statusCode: 401,
        );
        when(mockHttpService.get('/api/session'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.getSession();

        // Assert
        expect(result, null);
      });

      test('should handle session network error', () async {
        // Arrange
        when(mockHttpService.get('/api/session'))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/api/session'),
              type: DioExceptionType.connectionTimeout,
            ));

        // Act & Assert
        expect(
          () => apiService.getSession(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Device Management', () {
      test('should get devices successfully', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: [TestHelpers.sampleDeviceData],
          statusCode: 200,
        );
        when(mockHttpService.get('/api/devices'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.getDevices();

        // Assert
        expect(result, isA<List<Device>>());
        expect(result.length, 1);
        expect(result.first.name, 'Test Device');
        verify(mockHttpService.get('/api/devices'));
      });

      test('should get single device successfully', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: TestHelpers.sampleDeviceData,
          statusCode: 200,
        );
        when(mockHttpService.get('/api/devices/1'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.getDevice(1);

        // Assert
        expect(result, isA<Device>());
        expect(result?.name, 'Test Device');
        verify(mockHttpService.get('/api/devices/1'));
      });

      test('should handle device not found', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: null,
          statusCode: 404,
        );
        when(mockHttpService.get('/api/devices/999'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.getDevice(999);

        // Assert
        expect(result, null);
      });

      test('should handle devices network error', () async {
        // Arrange
        when(mockHttpService.get('/api/devices'))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/api/devices'),
              type: DioExceptionType.connectionError,
            ));

        // Act & Assert
        expect(
          () => apiService.getDevices(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Position Management', () {
      test('should get positions successfully', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: [TestHelpers.samplePositionData],
          statusCode: 200,
        );
        when(mockHttpService.get(
          '/api/positions',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.getPositions();

        // Assert
        expect(result, isA<List<Position>>());
        expect(result.length, 1);
        expect(result.first.latitude, 37.7749);
        verify(mockHttpService.get(
          '/api/positions',
          queryParameters: {},
        ));
      });

      test('should get positions with device IDs', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: [TestHelpers.samplePositionData],
          statusCode: 200,
        );
        when(mockHttpService.get(
          '/api/positions',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.getPositions(deviceIds: [1, 2]);

        // Assert
        expect(result, isA<List<Position>>());
        verify(mockHttpService.get(
          '/api/positions',
          queryParameters: {'deviceId': [1, 2]},
        ));
      });

      test('should get positions with time range', () async {
        // Arrange
        final from = DateTime(2024, 1, 1, 10, 0, 0);
        final to = DateTime(2024, 1, 1, 18, 0, 0);
        final mockResponse = TestHelpers.createMockResponse(
          data: [TestHelpers.samplePositionData],
          statusCode: 200,
        );
        when(mockHttpService.get(
          '/api/positions',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.getPositions(
          deviceIds: [1],
          from: from,
          to: to,
        );

        // Assert
        expect(result, isA<List<Position>>());
        verify(mockHttpService.get(
          '/api/positions',
          queryParameters: {
            'deviceId': [1],
            'from': from.toIso8601String(),
            'to': to.toIso8601String(),
          },
        ));
      });

      test('should handle positions network error', () async {
        // Arrange
        when(mockHttpService.get(
          '/api/positions',
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/positions'),
          type: DioExceptionType.connectionError,
        ));

        // Act & Assert
        expect(
          () => apiService.getPositions(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Event Management', () {
      test('should get events successfully', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: [TestHelpers.sampleEventData],
          statusCode: 200,
        );
        when(mockHttpService.get(
          '/api/events',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.getEvents();

        // Assert
        expect(result, isA<List<Event>>());
        expect(result.length, 1);
        expect(result.first.type, 'deviceOnline');
        verify(mockHttpService.get(
          '/api/events',
          queryParameters: {},
        ));
      });

      test('should get events with filters', () async {
        // Arrange
        final from = DateTime(2024, 1, 1, 10, 0, 0);
        final to = DateTime(2024, 1, 1, 18, 0, 0);
        final mockResponse = TestHelpers.createMockResponse(
          data: [TestHelpers.sampleEventData],
          statusCode: 200,
        );
        when(mockHttpService.get(
          '/api/events',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.getEvents(
          deviceIds: [1],
          from: from,
          to: to,
          types: ['deviceOnline', 'deviceOffline'],
        );

        // Assert
        expect(result, isA<List<Event>>());
        verify(mockHttpService.get(
          '/api/events',
          queryParameters: {
            'deviceId': [1],
            'from': from.toIso8601String(),
            'to': to.toIso8601String(),
            'type': ['deviceOnline', 'deviceOffline'],
          },
        ));
      });
    });

    group('Report Methods', () {
      test('should get trip reports successfully', () async {
        // Arrange
        final from = DateTime(2024, 1, 1, 0, 0, 0);
        final to = DateTime(2024, 1, 2, 0, 0, 0);
        final mockResponse = TestHelpers.createMockResponse(
          data: [TestHelpers.sampleTripData],
          statusCode: 200,
        );
        when(mockHttpService.get(
          '/api/reports/trips',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.getTripReports(
          deviceIds: [1],
          from: from,
          to: to,
        );

        // Assert
        expect(result, isA<List<Trips>>());
        expect(result.length, 1);
        expect(result.first.deviceName, 'Test Device');
        verify(mockHttpService.get(
          '/api/reports/trips',
          queryParameters: {
            'deviceId': [1],
            'from': from.toIso8601String(),
            'to': to.toIso8601String(),
          },
        ));
      });

      test('should get stops reports successfully', () async {
        // Arrange
        final from = DateTime(2024, 1, 1, 0, 0, 0);
        final to = DateTime(2024, 1, 2, 0, 0, 0);
        final mockResponse = TestHelpers.createMockResponse(
          data: [TestHelpers.sampleStopsData],
          statusCode: 200,
        );
        when(mockHttpService.get(
          '/api/reports/stops',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.getStopsReports(
          deviceIds: [1],
          from: from,
          to: to,
        );

        // Assert
        expect(result, isA<List<StopsReport>>());
        expect(result.length, 1);
        expect(result.first.deviceName, 'Test Device');
        verify(mockHttpService.get(
          '/api/reports/stops',
          queryParameters: {
            'deviceId': [1],
            'from': from.toIso8601String(),
            'to': to.toIso8601String(),
          },
        ));
      });

      test('should get summary reports successfully', () async {
        // Arrange
        final from = DateTime(2024, 1, 1, 0, 0, 0);
        final to = DateTime(2024, 1, 2, 0, 0, 0);
        final mockResponse = TestHelpers.createMockResponse(
          data: [TestHelpers.sampleSummaryData],
          statusCode: 200,
        );
        when(mockHttpService.get(
          '/api/reports/summary',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.getSummaryReports(
          deviceIds: [1],
          from: from,
          to: to,
        );

        // Assert
        expect(result, isA<List<ReportSummary>>());
        expect(result.length, 1);
        expect(result.first.deviceName, 'Test Device');
        verify(mockHttpService.get(
          '/api/reports/summary',
          queryParameters: {
            'deviceId': [1],
            'from': from.toIso8601String(),
            'to': to.toIso8601String(),
          },
        ));
      });

      test('should get distance reports successfully', () async {
        // Arrange
        final from = DateTime(2024, 1, 1, 0, 0, 0);
        final to = DateTime(2024, 1, 2, 0, 0, 0);
        final mockResponse = TestHelpers.createMockResponse(
          data: [TestHelpers.sampleDistanceData],
          statusCode: 200,
        );
        when(mockHttpService.get(
          '/api/reports/route',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.getDistanceReports(
          deviceIds: [1],
          from: from,
          to: to,
        );

        // Assert
        expect(result, isA<List<ReportDistance>>());
        expect(result.length, 1);
        expect(result.first.description, 'Daily Route');
        verify(mockHttpService.get(
          '/api/reports/route',
          queryParameters: {
            'deviceId': [1],
            'from': from.toIso8601String(),
            'to': to.toIso8601String(),
          },
        ));
      });
    });
  });
}