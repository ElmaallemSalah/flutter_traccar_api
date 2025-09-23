// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_traccar_api_example/main.dart';

void main() {
  testWidgets('Verify Traccar API Example App loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TraccarApiExampleApp());

    // Verify that the login screen is displayed.
    expect(
      find.byType(LoginScreen),
      findsOneWidget,
    );
    
    // Verify that login form elements are present.
    expect(find.text('Traccar API Login'), findsOneWidget);
    expect(find.text('Server URL'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
