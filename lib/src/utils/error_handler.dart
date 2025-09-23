import 'package:dio/dio.dart';
import '../exceptions/traccar_exceptions.dart';

/// Utility class for handling and converting errors to appropriate exceptions
class ErrorHandler {
  /// Converts Dio errors and other exceptions to appropriate TraccarException types
  static TraccarException handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    }
    
    if (error is TraccarException) {
      return error;
    }
    
    // Handle other types of errors
    return NetworkException(
      'Unexpected error occurred: ${error.toString()}',
      originalError: error,
    );
  }
  
  /// Handles Dio-specific errors
  static TraccarException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Connection timeout. Please check your internet connection.',
          statusCode: error.response?.statusCode,
          originalError: error,
        );
        
      case DioExceptionType.badResponse:
        return _handleHttpError(error);
        
      case DioExceptionType.cancel:
        return NetworkException(
          'Request was cancelled.',
          originalError: error,
        );
        
      case DioExceptionType.connectionError:
        return NetworkException(
          'Connection error. Please check your internet connection.',
          originalError: error,
        );
        
      case DioExceptionType.badCertificate:
        return NetworkException(
          'SSL certificate error. Please check server configuration.',
          originalError: error,
        );
        
      case DioExceptionType.unknown:
        return NetworkException(
          'Network error: ${error.message ?? "Unknown error"}',
          originalError: error,
        );
    }
  }
  
  /// Handles HTTP response errors based on status codes
  static TraccarException _handleHttpError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    
    switch (statusCode) {
      case 400:
        return ValidationException(
          _extractErrorMessage(responseData) ?? 'Bad request. Please check your input.',
          statusCode: statusCode,
          fieldErrors: _extractFieldErrors(responseData),
          originalError: error,
        );
        
      case 401:
        return AuthenticationException(
          _extractErrorMessage(responseData) ?? 'Authentication failed. Please check your credentials.',
          statusCode: statusCode,
          originalError: error,
        );
        
      case 403:
        return AuthorizationException(
          _extractErrorMessage(responseData) ?? 'Access denied. You do not have permission to access this resource.',
          statusCode: statusCode,
          originalError: error,
        );
        
      case 404:
        return NotFoundException(
          _extractErrorMessage(responseData) ?? 'Resource not found.',
          statusCode: statusCode,
          originalError: error,
        );
        
      case 429:
        return RateLimitException(
          _extractErrorMessage(responseData) ?? 'Rate limit exceeded. Please try again later.',
          statusCode: statusCode,
          retryAfter: _extractRetryAfter(error.response?.headers),
          originalError: error,
        );
        
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          _extractErrorMessage(responseData) ?? 'Server error. Please try again later.',
          statusCode: statusCode,
          originalError: error,
        );
        
      default:
        return ServerException(
          _extractErrorMessage(responseData) ?? 'HTTP error $statusCode',
          statusCode: statusCode,
          originalError: error,
        );
    }
  }
  
  /// Extracts error message from response data
  static String? _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return null;
    
    if (responseData is Map<String, dynamic>) {
      // Try common error message fields
      return responseData['message'] as String? ??
             responseData['error'] as String? ??
             responseData['detail'] as String? ??
             responseData['description'] as String?;
    }
    
    if (responseData is String) {
      return responseData;
    }
    
    return null;
  }
  
  /// Extracts field-specific validation errors from response data
  static Map<String, List<String>>? _extractFieldErrors(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) return null;
    
    final errors = responseData['errors'] ?? responseData['fieldErrors'];
    if (errors is! Map<String, dynamic>) return null;
    
    final fieldErrors = <String, List<String>>{};
    
    errors.forEach((key, value) {
      if (value is List) {
        fieldErrors[key] = value.map((e) => e.toString()).toList();
      } else if (value is String) {
        fieldErrors[key] = [value];
      }
    });
    
    return fieldErrors.isNotEmpty ? fieldErrors : null;
  }
  
  /// Extracts retry-after time from response headers
  static DateTime? _extractRetryAfter(Headers? headers) {
    if (headers == null) return null;
    
    final retryAfterHeader = headers.value('retry-after');
    if (retryAfterHeader == null) return null;
    
    // Try to parse as seconds
    final seconds = int.tryParse(retryAfterHeader);
    if (seconds != null) {
      return DateTime.now().add(Duration(seconds: seconds));
    }
    
    // Try to parse as HTTP date
    try {
      return DateTime.parse(retryAfterHeader);
    } catch (e) {
      return null;
    }
  }
  
  /// Validates required parameters and throws ValidationException if any are missing
  static void validateRequired(Map<String, dynamic> parameters) {
    final missingFields = <String>[];
    
    parameters.forEach((key, value) {
      if (value == null || (value is String && value.isEmpty)) {
        missingFields.add(key);
      }
    });
    
    if (missingFields.isNotEmpty) {
      throw ValidationException(
        'Missing required parameters: ${missingFields.join(", ")}',
        fieldErrors: {
          for (final field in missingFields) field: ['This field is required']
        },
      );
    }
  }
  
  /// Validates URL format
  static void validateUrl(String url, {String fieldName = 'url'}) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw ValidationException(
        'Invalid URL format: $url',
        fieldErrors: {
          fieldName: ['Please provide a valid URL with protocol (http/https)']
        },
      );
    }
  }
  
  /// Validates date range
  static void validateDateRange(DateTime? from, DateTime? to) {
    if (from != null && to != null && from.isAfter(to)) {
      throw ValidationException(
        'Start date cannot be after end date',
        fieldErrors: {
          'from': ['Start date must be before end date'],
          'to': ['End date must be after start date'],
        },
      );
    }
  }

  /// Validates device ID format
  static void validateDeviceId(String? deviceId) {
    if (deviceId == null || deviceId.isEmpty) {
      throw ValidationException(
        'Device ID is required',
        fieldErrors: {'deviceId': ['Device ID cannot be empty']},
      );
    }
    
    if (deviceId.length > 100) {
      throw ValidationException(
        'Device ID is too long',
        fieldErrors: {'deviceId': ['Device ID must be less than 100 characters']},
      );
    }
  }

  /// Validates pagination parameters
  static void validatePagination({int? page, int? limit}) {
    if (page != null && page < 0) {
      throw ValidationException(
        'Page number cannot be negative',
        fieldErrors: {'page': ['Page number must be 0 or greater']},
      );
    }
    
    if (limit != null && (limit <= 0 || limit > 1000)) {
      throw ValidationException(
        'Invalid limit value',
        fieldErrors: {'limit': ['Limit must be between 1 and 1000']},
      );
    }
  }

  /// Validates coordinates
  static void validateCoordinates({double? latitude, double? longitude}) {
    if (latitude != null && (latitude < -90 || latitude > 90)) {
      throw ValidationException(
        'Invalid latitude value',
        fieldErrors: {'latitude': ['Latitude must be between -90 and 90']},
      );
    }
    
    if (longitude != null && (longitude < -180 || longitude > 180)) {
      throw ValidationException(
        'Invalid longitude value',
        fieldErrors: {'longitude': ['Longitude must be between -180 and 180']},
      );
    }
  }

  /// Wraps async operations with error handling
  static Future<T> wrapAsync<T>(
    Future<T> Function() operation, {
    String? context,
  }) async {
    try {
      return await operation();
    } catch (error) {
      final traccarError = handleError(error);
      
      // Add context to error message if provided
      if (context != null) {
        throw _addContextToError(traccarError, context);
      }
      
      throw traccarError;
    }
  }

  /// Wraps sync operations with error handling
  static T wrapSync<T>(
    T Function() operation, {
    String? context,
  }) {
    try {
      return operation();
    } catch (error) {
      final traccarError = handleError(error);
      
      // Add context to error message if provided
      if (context != null) {
        throw _addContextToError(traccarError, context);
      }
      
      throw traccarError;
    }
  }

  /// Adds context information to an existing error
  static TraccarException _addContextToError(TraccarException error, String context) {
    final contextualMessage = '$context: ${error.message}';
    
    // Return the same type of exception with updated message
    if (error is AuthenticationException) {
      return AuthenticationException(
        contextualMessage,
        statusCode: error.statusCode,
        originalError: error.originalError,
      );
    } else if (error is AuthorizationException) {
      return AuthorizationException(
        contextualMessage,
        statusCode: error.statusCode,
        originalError: error.originalError,
      );
    } else if (error is ValidationException) {
      return ValidationException(
        contextualMessage,
        statusCode: error.statusCode,
        fieldErrors: error.fieldErrors,
        originalError: error.originalError,
      );
    } else if (error is NotFoundException) {
      return NotFoundException(
        contextualMessage,
        statusCode: error.statusCode,
        originalError: error.originalError,
      );
    } else if (error is NetworkException) {
      return NetworkException(
        contextualMessage,
        statusCode: error.statusCode,
        originalError: error.originalError,
      );
    } else if (error is ServerException) {
      return ServerException(
        contextualMessage,
        statusCode: error.statusCode,
        originalError: error.originalError,
      );
    } else if (error is RateLimitException) {
      return RateLimitException(
        contextualMessage,
        statusCode: error.statusCode,
        retryAfter: error.retryAfter,
        originalError: error.originalError,
      );
    }
    
    // For other types, return a generic TraccarException
    return NetworkException(
      contextualMessage,
      statusCode: error.statusCode,
      originalError: error.originalError,
    );
  }

  /// Checks if an error is retryable
  static bool isRetryableError(TraccarException error) {
    // Network errors are generally retryable
    if (error is NetworkException) {
      return true;
    }
    
    // Server errors (5xx) are retryable
    if (error is ServerException) {
      final statusCode = error.statusCode;
      return statusCode != null && statusCode >= 500 && statusCode < 600;
    }
    
    // Rate limit errors are retryable after waiting
    if (error is RateLimitException) {
      return true;
    }
    
    // Other errors are generally not retryable
    return false;
  }

  /// Gets suggested retry delay for retryable errors
  static Duration? getRetryDelay(TraccarException error) {
    if (error is RateLimitException && error.retryAfter != null) {
      final now = DateTime.now();
      final delay = error.retryAfter!.difference(now);
      return delay.isNegative ? Duration.zero : delay;
    }
    
    if (isRetryableError(error)) {
      // Default exponential backoff starting at 1 second
      return const Duration(seconds: 1);
    }
    
    return null;
  }
}