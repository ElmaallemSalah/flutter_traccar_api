/// Custom exceptions for Traccar API operations
/// 
/// This file defines specific exception types that can be thrown
/// during various Traccar API operations for better error handling.

/// Base exception class for all Traccar API related errors
abstract class TraccarException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const TraccarException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'TraccarException ($statusCode): $message';
    }
    return 'TraccarException: $message';
  }
}

/// Exception thrown when authentication fails
class AuthenticationException extends TraccarException {
  const AuthenticationException(
    super.message, {
    super.statusCode,
    super.originalError,
  });

  @override
  String toString() {
    return 'AuthenticationException: $message';
  }
}

/// Exception thrown when user is not authorized to access a resource
class AuthorizationException extends TraccarException {
  const AuthorizationException(
    super.message, {
    super.statusCode,
    super.originalError,
  });

  @override
  String toString() {
    return 'AuthorizationException: $message';
  }
}

/// Exception thrown when a network error occurs
class NetworkException extends TraccarException {
  const NetworkException(
    super.message, {
    super.statusCode,
    super.originalError,
  });

  @override
  String toString() {
    return 'NetworkException: $message';
  }
}

/// Exception thrown when server returns an error
class ServerException extends TraccarException {
  const ServerException(
    super.message, {
    super.statusCode,
    super.originalError,
  });

  @override
  String toString() {
    return 'ServerException: $message';
  }
}

/// Exception thrown when request validation fails
class ValidationException extends TraccarException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.statusCode,
    super.originalError,
  });

  @override
  String toString() {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      final errors = fieldErrors!.entries
          .map((e) => '${e.key}: ${e.value.join(", ")}')
          .join('; ');
      return 'ValidationException: $message. Field errors: $errors';
    }
    return 'ValidationException: $message';
  }
}

/// Exception thrown when a resource is not found
class NotFoundException extends TraccarException {
  const NotFoundException(
    super.message, {
    super.statusCode,
    super.originalError,
  });

  @override
  String toString() {
    return 'NotFoundException: $message';
  }
}

/// Exception thrown when rate limit is exceeded
class RateLimitException extends TraccarException {
  final DateTime? retryAfter;

  const RateLimitException(
    super.message, {
    this.retryAfter,
    super.statusCode,
    super.originalError,
  });

  @override
  String toString() {
    if (retryAfter != null) {
      return 'RateLimitException: $message. Retry after: $retryAfter';
    }
    return 'RateLimitException: $message';
  }
}

/// Exception thrown when secure storage operations fail
class StorageException extends TraccarException {
  const StorageException(
    super.message, {
    super.originalError,
  }) : super(statusCode: null);

  @override
  String toString() {
    return 'StorageException: $message';
  }
}

/// Exception thrown when configuration is invalid
class ConfigurationException extends TraccarException {
  const ConfigurationException(
    super.message, {
    super.originalError,
  }) : super(statusCode: null);

  @override
  String toString() {
    return 'ConfigurationException: $message';
  }
}