import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
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

  Map<String, dynamic>? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  DataService? _dataService;

  Map<String, dynamic>? get currentUser => _currentUser;
  String? get currentUserEmail => _currentUser?['email'];
  bool get isAuthenticated => _currentUser != null;
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

    try {
      final url = Uri.parse('${AppConstants.baseUrl}/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      _setLoading(false);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _currentUser = responseData['user'];
        _isAuthenticated = true;
        
        // Sign in to Firebase Anonymously to allow Storage uploads
        try {
          await FirebaseAuth.instance.signInAnonymously();
          if (kDebugMode) print('Firebase Anonymous Login Successful');
        } catch (e) {
          if (kDebugMode) print('Firebase Auth Error: $e');
          // Proceed anyway, storage uploads might fail but app login succeeded
        }

        notifyListeners();
        return true;
      } else {
        if (kDebugMode) {
          print('Login failed: ${response.statusCode} - ${response.body}');
        }
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      _currentUser = null;
      _isAuthenticated = false;
      _setLoading(false);
      notifyListeners();
      return false;
    }
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
  void logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (kDebugMode) print('Firebase SignOut Error: $e');
    }
    // _dataService?.logout();
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