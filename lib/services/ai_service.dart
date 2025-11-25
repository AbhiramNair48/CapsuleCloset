import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/clothing_item.dart';
import '../config/app_constants.dart';
import 'prompts.dart';
import 'inventory_formatter.dart';

class Message {
  final String text;
  final bool isUser;
  final List<String>? imagePaths;

  Message({
    required this.text,
    required this.isUser,
    this.imagePaths,
  });
}

class AIService extends ChangeNotifier {
  final List<Message> _messages = [];
  bool _isLoading = false;
  GenerativeModel? _model;
  ChatSession? _chatSession;

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  AIService() {
    _initModel();
  }

  void _initModel() {
    final apiKey = AppConstants.geminiApiKey;
    
    if (apiKey.isNotEmpty && apiKey != 'YOUR_API_KEY_HERE') {
      _model = GenerativeModel(
        model: AppConstants.geminiModel,
        apiKey: apiKey,
      );
    } else {
      debugPrint('WARNING: Gemini API Key not configured in AppConstants.');
    }
  }

  /// Starts a new chat session with optional context
  void startChat() {
    if (_messages.isEmpty) {
         _messages.add(Message(
        text: "Hello! I'm your personal stylist. How can I help you with your wardrobe today?",
        isUser: false,
      ));
    }
   
    if (_model != null && _chatSession == null) {
       _chatSession = _model!.startChat();
    }
    notifyListeners();
  }

  /// Sends a message to the AI, optionally including the current closet inventory context
  Future<void> sendMessage(String text) async {
    if (_model == null) {
      _messages.add(Message(text: text, isUser: true));
      _messages.add(Message(
        text: "Error: API Key not configured. Please set your API key in lib/config/app_constants.dart.", 
        isUser: false
      ));
      notifyListeners();
      return;
    }

    _isLoading = true;
    _messages.add(Message(text: text, isUser: true));
    notifyListeners();

    try {
      _chatSession ??= _model!.startChat();
      
      final response = await _chatSession!.sendMessage(Content.text(text));
      final responseText = response.text;

      if (responseText != null) {
        _messages.add(Message(text: responseText, isUser: false));
      } else {
        _messages.add(Message(text: "I'm sorry, I didn't understand that.", isUser: false));
      }
    } catch (e) {
      _messages.add(Message(text: "Error: $e", isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // A method to explicitly feed context if we want to restart the chat with context
  void updateContext(List<ClothingItem> items) {
    final apiKey = AppConstants.geminiApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') return;

    final inventoryString = InventoryFormatter.formatInventory(items);
    final systemPrompt = AppPrompts.stylistSystemPrompt.replaceAll('{{INVENTORY_LIST}}', inventoryString);
    
    _model = GenerativeModel(
        model: AppConstants.geminiModel,
        apiKey: apiKey,
        systemInstruction: Content.system(systemPrompt),
    );
    
    // Reset chat session with new model/instruction
    _chatSession = _model!.startChat();
  }
}