/// Mock authentication service for testing purposes.
/// This service simulates network requests with artificial delays.
class MockAuthService {
  static const Duration _networkDelay = Duration(seconds: 1);

  /// Simulated valid credentials for testing.
  static const List<Map<String, String>> _mockUsers = [
    {
      'email': 'test@example.com',
      'password': 'password123',
    },
    {
      'email': 'user@example.com',
      'password': 'testpass123',
    },
  ];

  /// Simulates a login attempt with network delay.
  /// Returns true if credentials match, false otherwise.
  static Future<bool> login(String email, String password) async {
    await Future.delayed(_networkDelay);
    
    return _mockUsers.any(
      (user) => user['email'] == email && user['password'] == password,
    );
  }

  /// Simulates a password reset request with network delay.
  /// Returns true if email exists, false otherwise.
  static Future<bool> resetPassword(String email) async {
    await Future.delayed(_networkDelay);
    
    return _mockUsers.any((user) => user['email'] == email);
  }
}