import 'dart:convert';
import 'package:dio/dio.dart';

/// Base HTTP service class that handles all network requests
/// with Dio integration and authentication support
class HttpService {
  late final Dio _dio;
  String? _baseUrl;
  String? _basicAuthToken;

  /// Creates an instance of HttpService with optional base URL
  HttpService({String? baseUrl}) {
    _baseUrl = baseUrl;
    _dio = Dio();
    _setupInterceptors();
  }

  /// Sets up Dio interceptors for request/response handling
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add base URL if provided
          if (_baseUrl != null && !options.path.startsWith('http')) {
            options.baseUrl = _baseUrl!;
          }

          // Add basic auth header if token is available
          if (_basicAuthToken != null) {
            options.headers['Authorization'] = 'Basic $_basicAuthToken';
          }

          // Set default content type
          options.headers['Content-Type'] = 'application/json';
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          // Handle common HTTP errors
          if (error.response?.statusCode == 401) {
            // Clear auth token on unauthorized
            _basicAuthToken = null;
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Sets the base URL for all requests
  void setBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
  }

  /// Sets the basic authentication token
  void setBasicAuthToken(String username, String password) {
    final credentials = base64Encode(utf8.encode('$username:$password'));
    _basicAuthToken = credentials;
  }

  /// Clears the authentication token
  void clearAuthToken() {
    _basicAuthToken = null;
  }

  /// Performs a GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Performs a POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Performs a PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Performs a DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Gets the current Dio instance for advanced usage
  Dio get dio => _dio;

  /// Checks if authentication token is set
  bool get isAuthenticated => _basicAuthToken != null;
}