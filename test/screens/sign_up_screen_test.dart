import 'package:capsule_closet_app/screens/sign_up_screen.dart';
import 'package:capsule_closet_app/services/auth_service.dart';
import 'package:capsule_closet_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class MockAuthService extends ChangeNotifier implements AuthService {
  bool _signUpSuccess = true;
  
  String? lastUsername;
  String? lastEmail;
  String? lastPassword;
  String? lastGender;
  String? lastFavoriteStyle;

  void setSignUpSuccess(bool success) {
    _signUpSuccess = success;
  }

  @override
  Future<bool> login(String email, String password) async {
    return true;
  }

  @override
  Future<bool> signUp(
    String username,
    String email,
    String password, {
    String? gender,
    String? favoriteStyle,
  }) async {
    lastUsername = username;
    lastEmail = email;
    lastPassword = password;
    lastGender = gender;
    lastFavoriteStyle = favoriteStyle;
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 10));
    return _signUpSuccess;
  }

  @override
  Future<bool> resetPassword(String email) async {
    return true;
  }

  @override
  String? get currentUserEmail => null;

  @override
  bool get isAuthenticated => false;

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

  Widget createSignUpScreen() {
    return ChangeNotifierProvider<AuthService>.value(
      value: mockAuthService,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const SignUpScreen(),
      ),
    );
  }

  testWidgets('SignUpScreen renders all fields correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createSignUpScreen());

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Gender (Optional)'), findsOneWidget);
    expect(find.text('Favorite Style (Optional)'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    
    // 6 TextFields: Username, Email, Gender, Style, Password, ConfirmPassword
    expect(find.byType(TextFormField), findsNWidgets(6));
  });

  testWidgets('SignUp passes correct data including optional fields', (WidgetTester tester) async {
    await tester.pumpWidget(createSignUpScreen());

    // Enter data
    await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Gender (Optional)'), 'Non-binary');
    await tester.enterText(find.widgetWithText(TextFormField, 'Favorite Style (Optional)'), 'Vintage');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');
    
    // Scroll to button if needed (SingleChildScrollView handles this usually)
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    
    await tester.pump(); // Start loading
    await tester.pump(const Duration(milliseconds: 50)); // Wait for future
    await tester.pumpAndSettle(); // Wait for navigation pop

    // Verify
    expect(mockAuthService.lastUsername, 'testuser');
    expect(mockAuthService.lastEmail, 'test@example.com');
    expect(mockAuthService.lastGender, 'Non-binary');
    expect(mockAuthService.lastFavoriteStyle, 'Vintage');
    expect(mockAuthService.lastPassword, 'password123');
  });

  testWidgets('SignUp works without optional fields', (WidgetTester tester) async {
    await tester.pumpWidget(createSignUpScreen());

    // Enter data excluding optional fields
    await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser2');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test2@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');
    
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pump(const Duration(milliseconds: 50)); 
    await tester.pumpAndSettle(); 

    // Verify
    expect(mockAuthService.lastUsername, 'testuser2');
    expect(mockAuthService.lastEmail, 'test2@example.com');
    expect(mockAuthService.lastGender, isNull);
    expect(mockAuthService.lastFavoriteStyle, isNull);
  });
}
