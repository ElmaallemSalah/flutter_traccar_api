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

/// Exception thrown when device operations fail
class DeviceException extends TraccarException {
  final String? deviceId;

  const DeviceException(
    super.message, {
    this.deviceId,
    super.statusCode,
    super.originalError,
  });

  @override
  String toString() {
    if (deviceId != null) {
      return 'DeviceException (Device: $deviceId): $message';
    }
    return 'DeviceException: $message';
  }
}

/// Exception thrown when command operations fail
class CommandException extends TraccarException {
  final String? commandType;
  final String? deviceId;

  const CommandException(
    super.message, {
    this.commandType,
    this.deviceId,
    super.statusCode,
    super.originalError,
  });

  @override
  String toString() {
    final details = <String>[];
    if (commandType != null) details.add('Command: $commandType');
    if (deviceId != null) details.add('Device: $deviceId');
    
    if (details.isNotEmpty) {
      return 'CommandException (${details.join(', ')}): $message';
    }
    return 'CommandException: $message';
  }
}

/// Exception thrown when report generation fails
class ReportException extends TraccarException {
  final String? reportType;
  final DateTime? from;
  final DateTime? to;

  const ReportException(
    super.message, {
    this.reportType,
    this.from,
    this.to,
    super.statusCode,
    super.originalError,
  });

  @override
  String toString() {
    final details = <String>[];
    if (reportType != null) details.add('Type: $reportType');
    if (from != null && to != null) {
      details.add('Period: ${from!.toIso8601String()} - ${to!.toIso8601String()}');
    }
    
    if (details.isNotEmpty) {
      return 'ReportException (${details.join(', ')}): $message';
    }
    return 'ReportException: $message';
  }
}

/// Exception thrown when geofence operations fail
class GeofenceException extends TraccarException {
  final String? geofenceId;

  const GeofenceException(
    super.message, {
    this.geofenceId,
    super.statusCode,
    super.originalError,
  });

  @override
  String toString() {
    if (geofenceId != null) {
      return 'GeofenceException (Geofence: $geofenceId): $message';
    }
    return 'GeofenceException: $message';
  }
}

/// Exception thrown when caching operations fail
class CacheException extends TraccarException {
  final String? cacheKey;

  const CacheException(
    super.message, {
    this.cacheKey,
    super.originalError,
  }) : super(statusCode: null);

  @override
  String toString() {
    if (cacheKey != null) {
      return 'CacheException (Key: $cacheKey): $message';
    }
    return 'CacheException: $message';
  }
}