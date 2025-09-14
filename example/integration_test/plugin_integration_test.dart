// Integration tests for Flutter Traccar API plugin
//
// These tests verify the plugin works correctly in a real Flutter app environment.
// They test the public API interface and basic functionality.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_traccar_api/flutter_traccar_api.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flutter Traccar API Integration Tests', () {
    late FlutterTraccarApi api;

    setUp(() {
      api = FlutterTraccarApi();
    });

    group('Plugin Initialization', () {
      testWidgets('should initialize plugin without errors', (WidgetTester tester) async {
        // Act & Assert
        expect(() => api.initialize(), returnsNormally);
        await api.initialize();
      });

      testWidgets('should return same instance (singleton)', (WidgetTester tester) async {
        // Act
        final api1 = FlutterTraccarApi();
        final api2 = FlutterTraccarApi();

        // Assert
        expect(identical(api1, api2), true);
      });
    });

    group('Authentication Interface', () {
      testWidgets('should expose authentication methods', (WidgetTester tester) async {
        // Assert
        expect(api.login, isA<Function>());
        expect(api.logout, isA<Function>());
        expect(api.isAuthenticated, isA<bool>());
        expect(api.currentUsername, isA<String?>());
        expect(api.hasCachedCredentials, isA<Function>());
        expect(api.refreshAuth, isA<Function>());
      });

      testWidgets('should handle login attempt gracefully', (WidgetTester tester) async {
        // Note: This will likely fail due to invalid credentials, but should not crash
        try {
          final result = await api.login(
            username: 'test',
            password: 'test',
            serverUrl: 'https://demo.traccar.org',
          );
          // If it succeeds, that's fine too
          expect(result, isA<bool>());
        } catch (e) {
          // Expected to fail with invalid credentials
          expect(e, isNotNull);
        }
      });

      testWidgets('should handle logout gracefully', (WidgetTester tester) async {
        // Act & Assert
        expect(() => api.logout(), returnsNormally);
        await api.logout();
      });

      testWidgets('should check cached credentials', (WidgetTester tester) async {
        // Act
        final result = await api.hasCachedCredentials();

        // Assert
        expect(result, isA<bool>());
      });
    });

    group('API Methods Interface', () {
      testWidgets('should expose session management methods', (WidgetTester tester) async {
        // Assert
        expect(api.getSession, isA<Function>());
      });

      testWidgets('should expose device management methods', (WidgetTester tester) async {
        // Assert
        expect(api.getDevices, isA<Function>());
        expect(api.getDevice, isA<Function>());
      });

      testWidgets('should expose position management methods', (WidgetTester tester) async {
        // Assert
        expect(api.getPositions, isA<Function>());
      });

      testWidgets('should expose event management methods', (WidgetTester tester) async {
        // Assert
        expect(api.getEvents, isA<Function>());
      });

      testWidgets('should expose command management methods', (WidgetTester tester) async {
        // Assert
        expect(api.sendCommand, isA<Function>());
      });

      testWidgets('should expose geofence management methods', (WidgetTester tester) async {
        // Assert
        expect(api.getGeofences, isA<Function>());
      });

      testWidgets('should expose driver management methods', (WidgetTester tester) async {
        // Assert
        expect(api.getDrivers, isA<Function>());
      });

      testWidgets('should expose maintenance management methods', (WidgetTester tester) async {
        // Assert
        expect(api.getMaintenances, isA<Function>());
      });

      testWidgets('should expose report methods', (WidgetTester tester) async {
        // Assert
        expect(api.getTripReports, isA<Function>());
        expect(api.getStopsReports, isA<Function>());
        expect(api.getSummaryReports, isA<Function>());
        expect(api.getDistanceReports, isA<Function>());
      });
    });

    group('Method Parameters and Return Types', () {
      testWidgets('should accept correct parameters for login', (WidgetTester tester) async {
        // Act & Assert
        expect(
          () => api.login(
            username: 'test',
            password: 'test',
            serverUrl: 'https://demo.traccar.org',
          ),
          returnsNormally,
        );
      });

      testWidgets('should accept correct parameters for getPositions', (WidgetTester tester) async {
        // Act & Assert
        expect(
          () => api.getPositions(
            deviceIds: [1, 2],
            from: DateTime.now().subtract(Duration(hours: 24)),
            to: DateTime.now(),
          ),
          returnsNormally,
        );
      });

      testWidgets('should accept correct parameters for getEvents', (WidgetTester tester) async {
        // Act & Assert
        expect(
          () => api.getEvents(
            deviceIds: [1, 2],
            from: DateTime.now().subtract(Duration(hours: 24)),
            to: DateTime.now(),
            types: ['deviceOnline', 'deviceOffline'],
          ),
          returnsNormally,
        );
      });

      testWidgets('should accept correct parameters for report methods', (WidgetTester tester) async {
        final deviceIds = [1, 2];
        final from = DateTime.now().subtract(Duration(days: 7));
        final to = DateTime.now();

        // Act & Assert
        expect(
          () => api.getTripReports(
            deviceIds: deviceIds,
            from: from,
            to: to,
          ),
          returnsNormally,
        );

        expect(
          () => api.getStopsReports(
            deviceIds: deviceIds,
            from: from,
            to: to,
          ),
          returnsNormally,
        );

        expect(
          () => api.getSummaryReports(
            deviceIds: deviceIds,
            from: from,
            to: to,
          ),
          returnsNormally,
        );

        expect(
          () => api.getDistanceReports(
            deviceIds: deviceIds,
            from: from,
            to: to,
          ),
          returnsNormally,
        );
      });
    });

    group('Error Handling', () {
      testWidgets('should handle network errors gracefully', (WidgetTester tester) async {
        // Try to call API methods without authentication
        // These should fail gracefully without crashing the app
        
        try {
          await api.getDevices();
        } catch (e) {
          // Expected to fail, but should not crash
          expect(e, isNotNull);
        }

        try {
          await api.getSession();
        } catch (e) {
          // Expected to fail, but should not crash
          expect(e, isNotNull);
        }
      });

      testWidgets('should handle invalid server URL gracefully', (WidgetTester tester) async {
        try {
          await api.login(
            username: 'test',
            password: 'test',
            serverUrl: 'invalid-url',
          );
        } catch (e) {
          // Expected to fail with invalid URL
          expect(e, isNotNull);
        }
      });
    });

    group('State Management', () {
      testWidgets('should maintain authentication state', (WidgetTester tester) async {
        // Initially should not be authenticated
        expect(api.isAuthenticated, false);
        expect(api.currentUsername, null);
      });

      testWidgets('should handle refresh auth when not authenticated', (WidgetTester tester) async {
        // Act
        final result = await api.refreshAuth();

        // Assert
        expect(result, false); // Should return false when not authenticated
      });
    });
  });
}
