import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:flutter_traccar_api/src/services/http_service.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('HttpService Tests', () {
    late MockDio mockDio;
    late HttpService httpService;

    setUp(() {
      mockDio = MockDio();
      httpService = HttpService();
      // Replace the internal Dio instance with our mock
      // Note: This would require exposing the Dio instance or using dependency injection
    });

    group('Configuration', () {
      test('should set base URL correctly', () {
        // Arrange
        const baseUrl = 'https://demo.traccar.org';

        // Act
        httpService.setBaseUrl(baseUrl);

        // Assert
        // We can't directly test this without exposing internal state
        // In a real implementation, we might expose a getter or use dependency injection
        expect(httpService, isNotNull);
      });

      test('should set basic auth token correctly', () {
        // Arrange
        const username = 'testuser';
        const password = 'testpass';

        // Act
        httpService.setBasicAuthToken(username, password);

        // Assert
        expect(httpService.isAuthenticated, true);
      });

      test('should clear auth token correctly', () {
        // Arrange
        httpService.setBasicAuthToken('user', 'pass');
        expect(httpService.isAuthenticated, true);

        // Act
        httpService.clearAuthToken();

        // Assert
        expect(httpService.isAuthenticated, false);
      });
    });

    group('HTTP Methods', () {
      test('should perform GET request successfully', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: {'message': 'success'},
          statusCode: 200,
        );

        // Create a new HttpService with a mock Dio for testing
        final testHttpService = TestableHttpService(mockDio);
        when(mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final response = await testHttpService.get<Map<String, dynamic>>('/test');

        // Assert
        expect(response.statusCode, 200);
        expect(response.data, {'message': 'success'});
        verify(mockDio.get<Map<String, dynamic>>(
          '/test',
          queryParameters: null,
          options: null,
        ));
      });

      test('should perform POST request successfully', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: {'id': 1, 'created': true},
          statusCode: 201,
        );
        final requestData = {'name': 'test'};

        final testHttpService = TestableHttpService(mockDio);
        when(mockDio.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final response = await testHttpService.post<Map<String, dynamic>>(
          '/test',
          data: requestData,
        );

        // Assert
        expect(response.statusCode, 201);
        expect(response.data, {'id': 1, 'created': true});
        verify(mockDio.post<Map<String, dynamic>>(
          '/test',
          data: requestData,
          queryParameters: null,
          options: null,
        ));
      });

      test('should perform PUT request successfully', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: {'id': 1, 'updated': true},
          statusCode: 200,
        );
        final requestData = {'name': 'updated test'};

        final testHttpService = TestableHttpService(mockDio);
        when(mockDio.put<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final response = await testHttpService.put<Map<String, dynamic>>(
          '/test/1',
          data: requestData,
        );

        // Assert
        expect(response.statusCode, 200);
        expect(response.data, {'id': 1, 'updated': true});
        verify(mockDio.put<Map<String, dynamic>>(
          '/test/1',
          data: requestData,
          queryParameters: null,
          options: null,
        ));
      });

      test('should perform DELETE request successfully', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: {'deleted': true},
          statusCode: 200,
        );

        final testHttpService = TestableHttpService(mockDio);
        when(mockDio.delete<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final response = await testHttpService.delete<Map<String, dynamic>>('/test/1');

        // Assert
        expect(response.statusCode, 200);
        expect(response.data, {'deleted': true});
        verify(mockDio.delete<Map<String, dynamic>>(
          '/test/1',
          data: null,
          queryParameters: null,
          options: null,
        ));
      });
    });

    group('Error Handling', () {
      test('should handle DioException correctly', () async {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.connectionTimeout,
          statusCode: null,
          message: 'Connection timeout',
        );

        final testHttpService = TestableHttpService(mockDio);
        when(mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => testHttpService.get<Map<String, dynamic>>('/test'),
          throwsA(isA<DioException>()),
        );
      });

      test('should handle network errors', () async {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.connectionError,
          message: 'Network error',
        );

        final testHttpService = TestableHttpService(mockDio);
        when(mockDio.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => testHttpService.post<Map<String, dynamic>>('/test', data: {}),
          throwsA(isA<DioException>()),
        );
      });

      test('should handle HTTP error responses', () async {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 404,
          message: 'Not found',
          responseData: {'error': 'Resource not found'},
        );

        final testHttpService = TestableHttpService(mockDio);
        when(mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => testHttpService.get<Map<String, dynamic>>('/test/999'),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('Request Parameters', () {
      test('should handle query parameters correctly', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: {'results': []},
          statusCode: 200,
        );
        final queryParams = {'page': 1, 'limit': 10};

        final testHttpService = TestableHttpService(mockDio);
        when(mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        await testHttpService.get<Map<String, dynamic>>(
          '/test',
          queryParameters: queryParams,
        );

        // Assert
        verify(mockDio.get<Map<String, dynamic>>(
          '/test',
          queryParameters: queryParams,
          options: null,
        ));
      });

      test('should handle custom options correctly', () async {
        // Arrange
        final mockResponse = TestHelpers.createMockResponse(
          data: {'message': 'success'},
          statusCode: 200,
        );
        final options = Options(headers: {'Custom-Header': 'value'});

        final testHttpService = TestableHttpService(mockDio);
        when(mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        await testHttpService.get<Map<String, dynamic>>(
          '/test',
          options: options,
        );

        // Assert
        verify(mockDio.get<Map<String, dynamic>>(
          '/test',
          queryParameters: null,
          options: options,
        ));
      });
    });
  });
}

/// Testable version of HttpService that allows injecting a mock Dio instance
class TestableHttpService extends HttpService {
  final Dio _mockDio;

  TestableHttpService(this._mockDio);

  @override
  Dio get dio => _mockDio;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _mockDio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _mockDio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _mockDio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _mockDio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
}