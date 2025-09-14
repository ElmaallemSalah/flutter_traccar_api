import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_traccar_api/src/utils/error_handler.dart';
import 'package:flutter_traccar_api/src/exceptions/traccar_exceptions.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ErrorHandler Tests', () {
    group('DioException Handling', () {
      test('should handle connection timeout', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timeout',
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<NetworkException>());
        expect(result.message, contains('Connection timeout'));
      });

      test('should handle send timeout', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.sendTimeout,
          message: 'Send timeout',
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<NetworkException>());
        expect(result.message, contains('Connection timeout'));
      });

      test('should handle receive timeout', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.receiveTimeout,
          message: 'Receive timeout',
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<NetworkException>());
        expect(result.message, contains('Connection timeout'));
      });

      test('should handle connection error', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.connectionError,
          message: 'Connection error',
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<NetworkException>());
        expect(result.message, contains('Connection error'));
      });

      test('should handle bad certificate', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badCertificate,
          message: 'Bad certificate',
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<NetworkException>());
        expect(result.message, contains('SSL certificate error'));
      });

      test('should handle request cancellation', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.cancel,
          message: 'Request cancelled',
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<NetworkException>());
        expect(result.message, contains('Request was cancelled'));
      });

      test('should handle unknown error', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.unknown,
          message: 'Unknown error',
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<NetworkException>());
        expect(result.message, contains('Network error'));
      });
    });

    group('HTTP Status Code Handling', () {
      test('should handle 400 Bad Request', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          responseData: {'message': 'Invalid request'},
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<ValidationException>());
        expect(result.statusCode, 400);
        expect(result.message, 'Invalid request');
      });

      test('should handle 401 Unauthorized', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 401,
          responseData: {'error': 'Authentication failed'},
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<AuthenticationException>());
        expect(result.statusCode, 401);
        expect(result.message, 'Authentication failed');
      });

      test('should handle 403 Forbidden', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 403,
          responseData: {'detail': 'Access denied'},
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<AuthorizationException>());
        expect(result.statusCode, 403);
        expect(result.message, 'Access denied');
      });

      test('should handle 404 Not Found', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 404,
          responseData: {'description': 'Resource not found'},
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<NotFoundException>());
        expect(result.statusCode, 404);
        expect(result.message, 'Resource not found');
      });

      test('should handle 429 Rate Limit', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 429,
          responseData: {'message': 'Rate limit exceeded'},
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<RateLimitException>());
        expect(result.statusCode, 429);
        expect(result.message, 'Rate limit exceeded');
      });

      test('should handle 500 Internal Server Error', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 500,
          responseData: {'error': 'Internal server error'},
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<ServerException>());
        expect(result.statusCode, 500);
        expect(result.message, 'Internal server error');
      });

      test('should handle 502 Bad Gateway', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 502,
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<ServerException>());
        expect(result.statusCode, 502);
      });

      test('should handle 503 Service Unavailable', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 503,
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<ServerException>());
        expect(result.statusCode, 503);
      });

      test('should handle 504 Gateway Timeout', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 504,
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<ServerException>());
        expect(result.statusCode, 504);
      });

      test('should handle unknown HTTP status code', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 418, // I'm a teapot
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result, isA<ServerException>());
        expect(result.statusCode, 418);
        expect(result.message, contains('HTTP error 418'));
      });
    });

    group('Error Message Extraction', () {
      test('should extract message from response data', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          responseData: {'message': 'Custom error message'},
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result.message, 'Custom error message');
      });

      test('should extract error from response data', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          responseData: {'error': 'Custom error'},
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result.message, 'Custom error');
      });

      test('should extract detail from response data', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          responseData: {'detail': 'Custom detail'},
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result.message, 'Custom detail');
      });

      test('should extract description from response data', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          responseData: {'description': 'Custom description'},
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result.message, 'Custom description');
      });

      test('should handle string response data', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          responseData: 'String error message',
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result.message, 'String error message');
      });

      test('should use default message when no message in response', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          responseData: {'other': 'data'},
        );

        // Act
        final result = ErrorHandler.handleError(dioException);

        // Assert
        expect(result.message, contains('Bad request'));
      });
    });

    group('Field Error Extraction', () {
      test('should extract field errors from validation response', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          responseData: {
            'message': 'Validation failed',
            'errors': {
              'username': ['This field is required'],
              'password': ['Password too short', 'Password too weak'],
            },
          },
        );

        // Act
        final result = ErrorHandler.handleError(dioException) as ValidationException;

        // Assert
        expect(result.fieldErrors, isNotNull);
        expect(result.fieldErrors!['username'], ['This field is required']);
        expect(result.fieldErrors!['password'], ['Password too short', 'Password too weak']);
      });

      test('should handle single string field errors', () {
        // Arrange
        final dioException = TestHelpers.createMockDioException(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          responseData: {
            'message': 'Validation failed',
            'fieldErrors': {
              'email': 'Invalid email format',
            },
          },
        );

        // Act
        final result = ErrorHandler.handleError(dioException) as ValidationException;

        // Assert
        expect(result.fieldErrors, isNotNull);
        expect(result.fieldErrors!['email'], ['Invalid email format']);
      });
    });

    group('Non-Dio Error Handling', () {
      test('should handle existing TraccarException', () {
        // Arrange
        final existingException = AuthenticationException('Already a TraccarException');

        // Act
        final result = ErrorHandler.handleError(existingException);

        // Assert
        expect(result, same(existingException));
      });

      test('should handle generic exceptions', () {
        // Arrange
        final genericException = Exception('Generic error');

        // Act
        final result = ErrorHandler.handleError(genericException);

        // Assert
        expect(result, isA<NetworkException>());
        expect(result.message, contains('Unexpected error occurred'));
        expect(result.originalError, same(genericException));
      });

      test('should handle string errors', () {
        // Arrange
        const stringError = 'String error';

        // Act
        final result = ErrorHandler.handleError(stringError);

        // Assert
        expect(result, isA<NetworkException>());
        expect(result.message, contains('String error'));
      });
    });

    group('Validation Helpers', () {
      test('should validate required parameters successfully', () {
        // Arrange
        final parameters = {
          'username': 'testuser',
          'password': 'testpass',
          'url': 'https://example.com',
        };

        // Act & Assert
        expect(
          () => ErrorHandler.validateRequired(parameters),
          returnsNormally,
        );
      });

      test('should throw ValidationException for missing parameters', () {
        // Arrange
        final parameters = {
          'username': 'testuser',
          'password': null,
          'url': '',
        };

        // Act & Assert
        expect(
          () => ErrorHandler.validateRequired(parameters),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate URL format successfully', () {
        // Act & Assert
        expect(
          () => ErrorHandler.validateUrl('https://example.com'),
          returnsNormally,
        );
      });

      test('should throw ValidationException for invalid URL', () {
        // Act & Assert
        expect(
          () => ErrorHandler.validateUrl('invalid-url'),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate date range successfully', () {
        // Arrange
        final from = DateTime(2024, 1, 1);
        final to = DateTime(2024, 1, 2);

        // Act & Assert
        expect(
          () => ErrorHandler.validateDateRange(from, to),
          returnsNormally,
        );
      });

      test('should throw ValidationException for invalid date range', () {
        // Arrange
        final from = DateTime(2024, 1, 2);
        final to = DateTime(2024, 1, 1);

        // Act & Assert
        expect(
          () => ErrorHandler.validateDateRange(from, to),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should allow null dates in range validation', () {
        // Act & Assert
        expect(
          () => ErrorHandler.validateDateRange(null, null),
          returnsNormally,
        );
      });
    });
  });
}