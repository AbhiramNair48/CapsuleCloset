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
}