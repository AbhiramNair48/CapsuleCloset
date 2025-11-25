import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/clothing_item.dart';

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
  bool get hasApiKey => _model != null;

  AIService() {
    _initModel();
  }

  void _initModel() {
    // Retrieve the API key from --dart-define=GEMINI_API_KEY=...
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    
    if (apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
    } else {
      debugPrint('WARNING: GEMINI_API_KEY not found in environment variables.');
    }
  }

  void setApiKey(String apiKey) {
    if (apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
      notifyListeners();
    }
  }

  /// Starts a new chat session with optional context
  void startChat() {
    // Clear previous messages if starting fresh, or keep them? 
    // If the model is null, we can't start a session, but we can show an error.
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
  Future<void> sendMessage(String text, {List<ClothingItem>? closetInventory}) async {
    if (_model == null) {
      _messages.add(Message(text: text, isUser: true));
      _messages.add(Message(
        text: "Error: API Key not configured. Please enter your API Key in the settings or restart with the key configured.", 
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
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) return;

    final inventoryDescription = items.map((item) => "${item.color} ${item.type} (${item.style}) - ${item.description}").join(", ");
    final prompt = "You are a helpful fashion stylist assistant. The user has the following items in their closet: $inventoryDescription. Please help them create outfits or answer fashion questions based on this inventory.";
    
    _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(prompt),
    );
    
    // Reset chat session with new model/instruction
    _chatSession = _model!.startChat();
    
    // We don't necessarily clear messages here to preserve history, 
    // but standard practice with system instruction change is often a new session.
    // For now, let's keep it simple.
  }
}