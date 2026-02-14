import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Retrieves the API key from the .env file
  static String get geminiLLMApiKey => dotenv.env['GEMINI_LLM_API_KEY'] ?? '';
  static String get geminiVisionApiKey => dotenv.env['GEMINI_VISION_API_KEY'] ?? '';
  
  // The Gemini Model to use
  static const String geminiModel = 'gemini-2.5-flash';

  // --- SERVER CONFIGURATION ---

  // 1. DEVELOPMENT (Your House):
  // Use your Pi's Local IP (Run 'hostname -I' on Pi to find it)
  // Example: 'http://192.168.1.50:8080'
  static const String _localUrl = 'http://192.168.1.175:8080';

  // 2. PRODUCTION (The World):
  // Your Global Public IP
  static const String _prodUrl = 'http://24.243.30.143:8080';

  // TOGGLE THIS: Set to 'true' before building for friends/App Store
  static const bool _isProduction = true;

  static String get baseUrl {
    // Web always requires the production URL if hosted externally, 
    // or local if debugging locally.
    if (kIsWeb && _isProduction) return _prodUrl;
    
    return _isProduction ? _prodUrl : _localUrl;
  }
}