import 'package:capsule_closet_app/screens/login_screen.dart';
import 'package:capsule_closet_app/services/auth_service.dart';
import 'package:capsule_closet_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class MockAuthService extends ChangeNotifier implements AuthService {
  bool _loginSuccess = true;
  
  void setLoginSuccess(bool success) {
    _loginSuccess = success;
  }

  @override
  Future<bool> login(String email, String password) async {
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 10));
    return _loginSuccess;
  }

  @override
  Future<bool> signUp(
    String username,
    String email,
    String password, {
    String? gender,
    String? favoriteStyle,
  }) async {
    return true;
  }

  @override
  Future<bool> resetPassword(String email) async {
    return true;
  }

  @override
  String? get currentUserEmail => 'test@example.com';

  @override
  bool get isAuthenticated => true;

  @override
  bool get isLoading => false;

  @override
  void logout() {}
}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  Widget createLoginScreen() {
    return ChangeNotifierProvider<AuthService>.value(
      value: mockAuthService,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
        routes: {
          '/closet': (_) => const Scaffold(body: Text('Closet Screen')),
        },
      ),
    );
  }

  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createLoginScreen());

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('Shows validation errors for empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(createLoginScreen());

    await tester.tap(find.text('Sign In'));
    await tester.pump(); // Rebuild

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('Navigates to closet on success', (WidgetTester tester) async {
    mockAuthService.setLoginSuccess(true);
    await tester.pumpWidget(createLoginScreen());

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    
    await tester.tap(find.text('Sign In'));
    await tester.pump(); // Start loading
    await tester.pump(const Duration(milliseconds: 50)); // Wait for future
    await tester.pumpAndSettle(); // Wait for navigation

    expect(find.text('Closet Screen'), findsOneWidget);
  });

  testWidgets('Shows error snackbar on failure', (WidgetTester tester) async {
    mockAuthService.setLoginSuccess(false);
    await tester.pumpWidget(createLoginScreen());

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');
    
    await tester.tap(find.text('Sign In'));
    await tester.pump(); // Start loading
    await tester.pump(const Duration(milliseconds: 50)); // Wait for future
    await tester.pump(); // Rebuild with error

    expect(find.text('Invalid email or password'), findsOneWidget);
  });
}
