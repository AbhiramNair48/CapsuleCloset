import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application constants and configuration
class AppConstants {
  // Retrieves the API key from the .env file
  static String get geminiLLMApiKey => dotenv.env['GEMINI_LLM_API_KEY'] ?? '';
  static String get geminiVisionApiKey => dotenv.env['GEMINI_VISION_API_KEY'] ?? '';
  
  // The Gemini Model to use
  // Using gemini-1.5-pro as the current stable "Pro" model. 
  // Can be updated to 'gemini-2.5-pro' when available in the API.
  static const String geminiModel = 'gemini-2.5-flash';

  static const String _baseUrl = '104.190.141.175:8080';
  static const String _androidUrl = 'http://10.0.2.2:8080';
  
  static String get baseUrl {
    if (kIsWeb) return _baseUrl;
    try {
      if (Platform.isAndroid) return _androidUrl;
    } catch (e) {
      // Platform.isAndroid might throw on web if not guarded by kIsWeb, 
      // but kIsWeb check above handles it.
      // Also handles case where dart:io is not fully supported?
    }
    return _baseUrl;
  }
}