import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';
import 'data_service.dart';

/// Authentication service for the application
class AuthService extends ChangeNotifier {
  static const Duration _networkDelay = Duration(seconds: 1);

  // Predefined constants for email addresses
  static const String emailTest = 'test@example.com';
  static const String emailUser = 'user@example.com';

  // Predefined constants for passwords
  static const String passwordTest = 'password123';
  static const String passwordUser = 'testpass123';

  // Predefined constants for valid credentials
  static const List<Map<String, String>> _validUsers = [
    {
      'email': emailTest,
      'password': passwordTest,
    },
    {
      'email': emailUser,
      'password': passwordUser,
    },
  ];

  String? _currentUserEmail;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  DataService? _dataService;

  String? get currentUserEmail => _currentUserEmail;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  /// Updates the DataService reference
  void updateDataService(DataService dataService) {
    _dataService = dataService;
  }

  /// Simulates a login attempt with network delay.
  /// Returns true if credentials match, false otherwise.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    await Future.delayed(_networkDelay);

    final isValid = _validUsers.any(
      (user) => user['email'] == email && user['password'] == password,
    );

    if (isValid) {
      _currentUserEmail = email;
      _isAuthenticated = true;
    } else {
      _currentUserEmail = null;
      _isAuthenticated = false;
    }

    _setLoading(false);
    notifyListeners();
    return _isAuthenticated;
  }

  /// Registers a new user with the backend.
  /// Returns true if registration is successful, false otherwise.
  Future<bool> signUp(
    String username,
    String email,
    String password, {
    String? gender,
    String? favoriteStyle,
  }) async {
    _setLoading(true);
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/signup');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'gender': gender,
          'favorite_style': favoriteStyle,
        }),
      );

      _setLoading(false);

      if (response.statusCode == 200) {
        // Automatically log in the user or just return success?
        // For now, let's just return success and let the UI navigate to login or home.
        // If we want auto-login, we would set _currentUserEmail and _isAuthenticated here.
        return true;
      } else {
        if (kDebugMode) {
          print('Signup failed: ${response.statusCode} - ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Signup error: $e');
      }
      _setLoading(false);
      return false;
    }
  }

  /// Logs out the current user
  void logout() {
    _currentUserEmail = null;
    _isAuthenticated = false;
    _dataService?.logout();
    notifyListeners();
  }

  /// Simulates a password reset request with network delay.
  /// Returns true if email exists, false otherwise.
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    await Future.delayed(_networkDelay);

    final exists = _validUsers.any((user) => user['email'] == email);
    _setLoading(false);
    notifyListeners();
    return exists;
  }

  /// Sets the loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}