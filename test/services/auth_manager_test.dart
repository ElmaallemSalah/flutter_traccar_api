import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_traccar_api/src/services/auth_manager.dart';
import 'package:flutter_traccar_api/src/services/http_service.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('AuthManager Tests', () {
    late MockFlutterSecureStorage mockSecureStorage;
    late MockHttpService mockHttpService;
    late AuthManager authManager;

    setUp(() {
      mockSecureStorage = MockFlutterSecureStorage();
      mockHttpService = MockHttpService();
      authManager = AuthManager(
        secureStorage: mockSecureStorage,
        httpService: mockHttpService,
      );
    });

    group('Initialization', () {
      test('should initialize without cached credentials', () async {
        // Arrange
        when(mockSecureStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);

        // Act
        await authManager.initialize();

        // Assert
        expect(authManager.isAuthenticated, false);
        expect(authManager.currentUsername, null);
        expect(authManager.baseUrl, null);
      });

      test('should initialize with cached credentials', () async {
        // Arrange
        when(mockSecureStorage.read(key: 'traccar_username'))
            .thenAnswer((_) async => 'testuser');
        when(mockSecureStorage.read(key: 'traccar_password'))
            .thenAnswer((_) async => 'testpass');
        when(mockSecureStorage.read(key: 'traccar_base_url'))
            .thenAnswer((_) async => 'https://demo.traccar.org');

        // Act
        await authManager.initialize();

        // Assert
        expect(authManager.isAuthenticated, true);
        expect(authManager.currentUsername, 'testuser');
        expect(authManager.baseUrl, 'https://demo.traccar.org');
        verify(mockHttpService.setBasicAuthToken('testuser', 'testpass'));
        verify(mockHttpService.setBaseUrl('https://demo.traccar.org'));
      });

      test('should handle storage errors gracefully during initialization', () async {
        // Arrange
        when(mockSecureStorage.read(key: anyNamed('key')))
            .thenThrow(Exception('Storage error'));

        // Act
        await authManager.initialize();

        // Assert
        expect(authManager.isAuthenticated, false);
      });
    });

    group('Login', () {
      test('should login successfully with valid credentials', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: TestHelpers.sampleSessionData,
          statusCode: 200,
        );
        when(mockHttpService.get('/api/session'))
            .thenAnswer((_) async => mockResponse);
        when(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});

        // Act
        final result = await authManager.login(
          username: 'testuser',
          password: 'testpass',
          baseUrl: 'https://demo.traccar.org',
        );

        // Assert
        expect(result, true);
        expect(authManager.isAuthenticated, true);
        expect(authManager.currentUsername, 'testuser');
        expect(authManager.baseUrl, 'https://demo.traccar.org');
        
        verify(mockHttpService.setBaseUrl('https://demo.traccar.org'));
        verify(mockHttpService.setBasicAuthToken('testuser', 'testpass'));
        verify(mockSecureStorage.write(key: 'traccar_username', value: 'testuser'));
        verify(mockSecureStorage.write(key: 'traccar_password', value: 'testpass'));
        verify(mockSecureStorage.write(key: 'traccar_base_url', value: 'https://demo.traccar.org'));
      });

      test('should fail login with invalid credentials', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: null,
          statusCode: 401,
        );
        when(mockHttpService.get('/api/session'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await authManager.login(
          username: 'invalid',
          password: 'invalid',
          baseUrl: 'https://demo.traccar.org',
        );

        // Assert
        expect(result, false);
        expect(authManager.isAuthenticated, false);
        verify(mockHttpService.clearAuthToken());
        verifyNever(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')));
      });

      test('should handle network errors during login', () async {
        // Arrange
        when(mockHttpService.get('/api/session'))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/api/session'),
              type: DioExceptionType.connectionTimeout,
            ));

        // Act
        final result = await authManager.login(
          username: 'testuser',
          password: 'testpass',
          baseUrl: 'https://demo.traccar.org',
        );

        // Assert
        expect(result, false);
        expect(authManager.isAuthenticated, false);
        verify(mockHttpService.clearAuthToken());
      });

      test('should handle storage errors during credential caching', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: TestHelpers.sampleSessionData,
          statusCode: 200,
        );
        when(mockHttpService.get('/api/session'))
            .thenAnswer((_) async => mockResponse);
        when(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => authManager.login(
            username: 'testuser',
            password: 'testpass',
            baseUrl: 'https://demo.traccar.org',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Logout', () {
      test('should logout successfully', () async {
        // Arrange
        when(mockSecureStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});

        // Act
        await authManager.logout();

        // Assert
        expect(authManager.isAuthenticated, false);
        expect(authManager.currentUsername, null);
        expect(authManager.baseUrl, null);
        
        verify(mockHttpService.clearAuthToken());
        verify(mockSecureStorage.delete(key: 'traccar_username'));
        verify(mockSecureStorage.delete(key: 'traccar_password'));
        verify(mockSecureStorage.delete(key: 'traccar_base_url'));
      });

      test('should handle storage errors during logout', () async {
        // Arrange
        when(mockSecureStorage.delete(key: anyNamed('key')))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => authManager.logout(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Credential Management', () {
      test('should detect cached credentials', () async {
        // Arrange
        when(mockSecureStorage.read(key: 'traccar_username'))
            .thenAnswer((_) async => 'testuser');
        when(mockSecureStorage.read(key: 'traccar_password'))
            .thenAnswer((_) async => 'testpass');

        // Act
        final result = await authManager.hasCachedCredentials();

        // Assert
        expect(result, true);
      });

      test('should detect missing cached credentials', () async {
        // Arrange
        when(mockSecureStorage.read(key: 'traccar_username'))
            .thenAnswer((_) async => null);
        when(mockSecureStorage.read(key: 'traccar_password'))
            .thenAnswer((_) async => 'testpass');

        // Act
        final result = await authManager.hasCachedCredentials();

        // Assert
        expect(result, false);
      });

      test('should handle storage errors when checking cached credentials', () async {
        // Arrange
        when(mockSecureStorage.read(key: anyNamed('key')))
            .thenThrow(Exception('Storage error'));

        // Act
        final result = await authManager.hasCachedCredentials();

        // Assert
        expect(result, false);
      });
    });

    group('Authentication Refresh', () {
      test('should refresh authentication successfully', () async {
        // Arrange
        authManager = AuthManager(
          secureStorage: mockSecureStorage,
          httpService: mockHttpService,
        );
        
        // Set up authenticated state
        when(mockSecureStorage.read(key: 'traccar_username'))
            .thenAnswer((_) async => 'testuser');
        when(mockSecureStorage.read(key: 'traccar_password'))
            .thenAnswer((_) async => 'testpass');
        when(mockSecureStorage.read(key: 'traccar_base_url'))
            .thenAnswer((_) async => 'https://demo.traccar.org');
        
        await authManager.initialize();
        
        final mockResponse = TestHelpers.createMockResponse(
          data: TestHelpers.sampleSessionData,
          statusCode: 200,
        );
        when(mockHttpService.get('/api/session'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await authManager.refreshAuth();

        // Assert
        expect(result, true);
        expect(authManager.isAuthenticated, true);
      });

      test('should fail refresh with invalid credentials', () async {
        // Arrange
        authManager = AuthManager(
          secureStorage: mockSecureStorage,
          httpService: mockHttpService,
        );
        
        // Set up authenticated state
        when(mockSecureStorage.read(key: 'traccar_username'))
            .thenAnswer((_) async => 'testuser');
        when(mockSecureStorage.read(key: 'traccar_password'))
            .thenAnswer((_) async => 'testpass');
        when(mockSecureStorage.read(key: 'traccar_base_url'))
            .thenAnswer((_) async => 'https://demo.traccar.org');
        
        await authManager.initialize();
        
        final mockResponse = TestHelpers.createMockResponse(
          data: null,
          statusCode: 401,
        );
        when(mockHttpService.get('/api/session'))
            .thenAnswer((_) async => mockResponse);
        when(mockSecureStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});

        // Act
        final result = await authManager.refreshAuth();

        // Assert
        expect(result, false);
        expect(authManager.isAuthenticated, false);
      });

      test('should return false when not authenticated', () async {
        // Act
        final result = await authManager.refreshAuth();

        // Assert
        expect(result, false);
      });

      test('should handle network errors during refresh', () async {
        // Arrange
        authManager = AuthManager(
          secureStorage: mockSecureStorage,
          httpService: mockHttpService,
        );
        
        // Set up authenticated state
        when(mockSecureStorage.read(key: 'traccar_username'))
            .thenAnswer((_) async => 'testuser');
        when(mockSecureStorage.read(key: 'traccar_password'))
            .thenAnswer((_) async => 'testpass');
        when(mockSecureStorage.read(key: 'traccar_base_url'))
            .thenAnswer((_) async => 'https://demo.traccar.org');
        
        await authManager.initialize();
        
        when(mockHttpService.get('/api/session'))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/api/session'),
              type: DioExceptionType.connectionTimeout,
            ));

        // Act
        final result = await authManager.refreshAuth();

        // Assert
        expect(result, false);
      });
    });
  });
}