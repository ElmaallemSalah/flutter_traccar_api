import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'http_service.dart';

/// Authentication manager that handles login, logout, and credential caching
/// using secure storage for persistent authentication state
class AuthManager {
  static const String _usernameKey = 'traccar_username';
  static const String _passwordKey = 'traccar_password';
  static const String _baseUrlKey = 'traccar_base_url';

  final FlutterSecureStorage _secureStorage;
  final HttpService _httpService;

  String? _currentUsername;
  String? _currentPassword;
  String? _baseUrl;
  bool _isAuthenticated = false;

  /// Creates an instance of AuthManager with secure storage and HTTP service
  AuthManager({
    FlutterSecureStorage? secureStorage,
    HttpService? httpService,
    HttpClientConfig? httpConfig,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _httpService =
           httpService ??
           HttpService(
             config:
                 httpConfig ??
                 const HttpClientConfig(
                   enableLogging: kDebugMode,
                   maxRetries: 3,
                   connectTimeout: Duration(seconds: 30),
                   receiveTimeout: Duration(seconds: 30),
                 ),
           );

  /// Initializes the auth manager by loading cached credentials
  Future<void> initialize() async {
    await _loadCachedCredentials();
  }

  /// Loads cached credentials from secure storage
  Future<void> _loadCachedCredentials() async {
    try {
      _currentUsername = await _secureStorage.read(key: _usernameKey);
      _currentPassword = await _secureStorage.read(key: _passwordKey);
      _baseUrl = await _secureStorage.read(key: _baseUrlKey);

      if (_currentUsername != null && _currentPassword != null) {
        _httpService.setBasicAuthToken(_currentUsername!, _currentPassword!);
        if (_baseUrl != null) {
          _httpService.setBaseUrl(_baseUrl!);
        }
        _isAuthenticated = true;
      }
    } catch (e) {
      // Handle storage errors gracefully
      _isAuthenticated = false;
    }
  }

  /// Performs login with username and password
  /// Returns true if login is successful, false otherwise
  Future<bool> login({
    required String username,
    required String password,
    required String baseUrl,
  }) async {
    try {
      // Set up HTTP service with credentials
      _httpService.setBaseUrl(baseUrl);
      _httpService.setBasicAuthToken(username, password);

      // Perform login by posting credentials to session endpoint
      final response = await _httpService.post(
        '/api/session',
        data: {'email': username, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        // Login successful, cache credentials
        await _cacheCredentials(username, password, baseUrl);
        _currentUsername = username;
        _currentPassword = password;
        _baseUrl = baseUrl;
        _isAuthenticated = true;
        return true;
      } else {
        _httpService.clearAuthToken();
        _isAuthenticated = false;
        return false;
      }
    } catch (e) {
      // Login failed due to network or other error
      _httpService.clearAuthToken();
      _isAuthenticated = false;
      return false;
    }
  }

  /// Caches credentials securely
  Future<void> _cacheCredentials(
    String username,
    String password,
    String baseUrl,
  ) async {
    try {
      await Future.wait([
        _secureStorage.write(key: _usernameKey, value: username),
        _secureStorage.write(key: _passwordKey, value: password),
        _secureStorage.write(key: _baseUrlKey, value: baseUrl),
      ]);
    } catch (e) {
      // Handle storage errors
      throw Exception('Failed to cache credentials: $e');
    }
  }

  /// Performs logout and clears cached credentials
  Future<void> logout() async {
    try {
      // Clear HTTP service authentication
      _httpService.clearAuthToken();

      // Clear cached credentials
      await _clearCachedCredentials();

      // Reset internal state
      _currentUsername = null;
      _currentPassword = null;
      _baseUrl = null;
      _isAuthenticated = false;
    } catch (e) {
      // Handle logout errors
      throw Exception('Failed to logout: $e');
    }
  }

  /// Clears all cached credentials from secure storage
  Future<void> _clearCachedCredentials() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _usernameKey),
        _secureStorage.delete(key: _passwordKey),
        _secureStorage.delete(key: _baseUrlKey),
      ]);
    } catch (e) {
      // Handle storage errors
      throw Exception('Failed to clear cached credentials: $e');
    }
  }

  /// Checks if user is currently authenticated
  bool get isAuthenticated => _isAuthenticated;

  /// Gets the current username (if authenticated)
  String? get currentUsername => _currentUsername;

  /// Gets the current base URL (if set)
  String? get baseUrl => _baseUrl;

  /// Gets the HTTP service instance for making authenticated requests
  HttpService get httpService => _httpService;

  /// Validates if credentials are cached
  Future<bool> hasCachedCredentials() async {
    try {
      final username = await _secureStorage.read(key: _usernameKey);
      final password = await _secureStorage.read(key: _passwordKey);
      return username != null && password != null;
    } catch (e) {
      return false;
    }
  }

  /// Refreshes authentication state by re-validating cached credentials
  Future<bool> refreshAuth() async {
    if (!_isAuthenticated ||
        _currentUsername == null ||
        _currentPassword == null) {
      return false;
    }

    try {
      // Test current credentials
      final response = await _httpService.get('/api/session');
      if (response.statusCode == 200) {
        return true;
      } else {
        // Credentials are no longer valid
        await logout();
        return false;
      }
    } catch (e) {
      // Network error or other issue
      return false;
    }
  }
}
