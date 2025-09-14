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
      default:
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
  static void validateRequired(Map<String, dynamic?> parameters) {
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
}