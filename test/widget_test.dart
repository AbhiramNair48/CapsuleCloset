// This is a basic Flutter widget test for the Capsule Closet app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:capsule_closet_app/main.dart';
import 'package:capsule_closet_app/services/auth_service.dart';
import 'package:capsule_closet_app/services/data_service.dart';

void main() {
  testWidgets('App initializes with providers', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app contains the expected elements
    expect(find.byType(Scaffold), findsWidgets);
    expect(find.byType(TextField), findsNWidgets(2)); // Email and password fields expected
    expect(find.byType(Image), findsNWidgets(2)); // Logo and bottom image
  });

  testWidgets('AuthService initializes correctly', (WidgetTester tester) async {
    // Create a test widget that uses the auth service
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthService(),
          child: Builder(
            builder: (context) {
              final authService = Provider.of<AuthService>(context);
              return Text(
                'Authenticated: ${authService.isAuthenticated}',
                key: const Key('auth-status'),
              );
            },
          ),
        ),
      ),
    );

    // Initially, the user should not be authenticated
    expect(find.text('Authenticated: false'), findsOneWidget);
  });

  testWidgets('DataService initializes with data', (WidgetTester tester) async {
    // Create a test widget that uses the data service
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => DataService(),
          child: Builder(
            builder: (context) {
              final dataService = Provider.of<DataService>(context);
              return Text(
                'Items: ${dataService.clothingItems.length}',
                key: const Key('item-count'),
              );
            },
          ),
        ),
      ),
    );

    // DataService should initialize with mock clothing items
    expect(find.byKey(const Key('item-count')), findsOneWidget);
  });
}
