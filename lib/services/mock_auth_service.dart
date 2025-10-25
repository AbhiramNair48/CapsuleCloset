// Mock authentication service for testing purposes
class MockAuthService {
  // Simulated valid credentials
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

  // Simulate login with delay to mimic network request
  static Future<bool> login(String email, String password) async {
    // Add artificial delay to simulate network request
    await Future.delayed(const Duration(seconds: 1));
    
    return _mockUsers.any(
      (user) => user['email'] == email && user['password'] == password,
    );
  }

  // Simulate password reset with delay
  static Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return _mockUsers.any((user) => user['email'] == email);
  }
}