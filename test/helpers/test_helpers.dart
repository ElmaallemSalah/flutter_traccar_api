import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_traccar_api/src/services/http_service.dart';
import 'package:flutter_traccar_api/src/services/auth_manager.dart';
import 'package:flutter_traccar_api/src/services/traccar_api_service.dart';

// Generate mocks for these classes
@GenerateMocks([
  FlutterSecureStorage,
  Dio,
  HttpService,
  AuthManager,
  TraccarApiService,
])
void main() {}

/// Test helper utilities for Flutter Traccar API tests
class TestHelpers {
  /// Creates a mock Response object for Dio
  static Response<T> createMockResponse<T>({
    required T data,
    int statusCode = 200,
    String statusMessage = 'OK',
    Map<String, dynamic>? headers,
    RequestOptions? requestOptions,
  }) {
    return Response<T>(
      data: data,
      statusCode: statusCode,
      statusMessage: statusMessage,
      headers: Headers.fromMap(headers?.map((k, v) => MapEntry(k, [v.toString()])) ?? {}),
      requestOptions: requestOptions ?? RequestOptions(path: '/test'),
    );
  }

  /// Creates a mock DioException
  static DioException createMockDioException({
    DioExceptionType type = DioExceptionType.unknown,
    int? statusCode,
    String message = 'Test error',
    dynamic responseData,
  }) {
    final requestOptions = RequestOptions(path: '/test');
    Response? response;
    
    if (statusCode != null) {
      response = Response(
        statusCode: statusCode,
        data: responseData,
        requestOptions: requestOptions,
      );
    }

    return DioException(
      requestOptions: requestOptions,
      response: response,
      type: type,
      message: message,
    );
  }

  /// Sample device data for testing
  static Map<String, dynamic> get sampleDeviceData => {
    'id': 1,
    'name': 'Test Device',
    'uniqueId': 'test123',
    'status': 'online',
    'lastUpdate': '2024-01-01T12:00:00Z',
    'positionId': 1,
    'groupId': null,
    'calendarId': null,
    'phone': null,
    'model': 'Test Model',
    'contact': null,
    'category': 'car',
    'disabled': false,
    'expirationTime': null,
    'attributes': {},
  };

  /// Sample position data for testing
  static Map<String, dynamic> get samplePositionData => {
    'id': 1,
    'deviceId': 1,
    'protocol': 'osmand',
    'deviceTime': '2024-01-01T12:00:00Z',
    'fixTime': '2024-01-01T12:00:00Z',
    'serverTime': '2024-01-01T12:00:00Z',
    'outdated': false,
    'valid': true,
    'latitude': 37.7749,
    'longitude': -122.4194,
    'altitude': 0.0,
    'speed': 0.0,
    'course': 0.0,
    'address': 'San Francisco, CA',
    'accuracy': 10.0,
    'network': null,
    'attributes': {
      'ignition': true,
      'motion': false,
      'batteryLevel': 85,
    },
  };

  /// Sample event data for testing
  static Map<String, dynamic> get sampleEventData => {
    'id': 1,
    'deviceId': 1,
    'type': 'deviceOnline',
    'eventTime': '2024-01-01T12:00:00Z',
    'positionId': 1,
    'geofenceId': null,
    'maintenanceId': null,
    'attributes': {},
  };

  /// Sample session data for testing
  static Map<String, dynamic> get sampleSessionData => {
    'id': 1,
    'name': 'Test User',
    'login': 'testuser',
    'email': 'test@example.com',
    'phone': null,
    'readonly': false,
    'administrator': true,
    'map': null,
    'latitude': 0.0,
    'longitude': 0.0,
    'zoom': 0,
    'coordinateFormat': null,
    'disabled': false,
    'expirationTime': null,
    'deviceLimit': -1,
    'userLimit': 0,
    'deviceReadonly': false,
    'limitCommands': false,
    'disableReports': false,
    'fixedEmail': false,
    'poiLayer': null,
    'totpKey': null,
    'temporary': false,
    'attributes': {},
  };

  /// Sample trip report data for testing
  static Map<String, dynamic> get sampleTripData => {
    'deviceId': 1,
    'deviceName': 'Test Device',
    'maxSpeed': 60.0,
    'averageSpeed': 45.0,
    'distance': 1000.0,
    'spentFuel': 5.5,
    'duration': 3600000, // 1 hour in milliseconds
    'startTime': '2024-01-01T10:00:00Z',
    'startAddress': 'Start Location',
    'startLat': 37.7749,
    'startLon': -122.4194,
    'endTime': '2024-01-01T11:00:00Z',
    'endAddress': 'End Location',
    'endLat': 37.7849,
    'endLon': -122.4094,
    'driverUniqueId': null,
    'driverName': null,
  };

  /// Sample stops report data for testing
  static Map<String, dynamic> get sampleStopsData => {
    'deviceId': 1,
    'deviceName': 'Test Device',
    'duration': 1800000, // 30 minutes in milliseconds
    'startTime': '2024-01-01T12:00:00Z',
    'address': 'Stop Location',
    'latitude': 37.7749,
    'longitude': -122.4194,
    'endTime': '2024-01-01T12:30:00Z',
    'spentFuel': 0.0,
    'engineHours': 0,
  };

  /// Sample summary report data for testing
  static Map<String, dynamic> get sampleSummaryData => {
    'deviceId': 1,
    'deviceName': 'Test Device',
    'distance': 1500.0,
    'averageSpeed': 50.0,
    'maxSpeed': 80.0,
    'spentFuel': 8.2,
    'startOdometer': 10000.0,
    'endOdometer': 11500.0,
    'startTime': '2024-01-01T08:00:00Z',
    'endTime': '2024-01-01T18:00:00Z',
    'startHours': 0,
    'endHours': 0,
    'engineHours': 7200000, // 2 hours in milliseconds
    'status': 'online',
  };

  /// Sample distance report data for testing
  static Map<String, dynamic> get sampleDistanceData => {
    'description': 'Daily Route',
    'start_km': 10000,
    'end_km': 11500,
    'distance': 1500,
    'date': '2024-01-01',
  };

  /// Sample geofence data for testing
  static Map<String, dynamic> get sampleGeofenceData => {
    'id': 1,
    'name': 'Test Geofence',
    'description': 'Test geofence description',
    'area': 'CIRCLE (37.7749 -122.4194, 100)',
    'calendarId': null,
    'attributes': {},
  };

  /// Sample driver data for testing
  static Map<String, dynamic> get sampleDriverData => {
    'id': 1,
    'name': 'Test Driver',
    'uniqueId': 'driver123',
    'attributes': {},
  };

  /// Sample maintenance data for testing
  static Map<String, dynamic> get sampleMaintenanceData => {
    'id': 1,
    'name': 'Oil Change',
    'type': 'maintenance',
    'start': 10000.0,
    'period': 5000.0,
    'attributes': {},
  };

  /// Sample command data for testing
  static Map<String, dynamic> get sampleCommandData => {
    'id': 1,
    'deviceId': 1,
    'type': 'positionSingle',
    'textChannel': false,
    'description': 'Request position',
    'attributes': {},
  };

  /// Sample notification data for testing
  static Map<String, dynamic> get sampleNotificationData => {
    'id': 1,
    'type': 'deviceOnline',
    'always': false,
    'web': true,
    'mail': false,
    'sms': false,
    'calendarId': null,
    'notificators': null,
    'attributes': {},
  };
}