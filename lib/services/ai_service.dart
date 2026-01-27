import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/clothing_item.dart';
import '../config/app_constants.dart';
import 'prompts.dart';
import 'inventory_formatter.dart';
import '../models/user_profile.dart';

class Message {
  final String text;
  final bool isUser;
  final List<String>? imagePaths;
  final List<String>? itemIds;
  bool hasAnimated; // Track if the typing animation has already played

  Message({
    required this.text,
    required this.isUser,
    this.imagePaths,
    this.itemIds,
    this.hasAnimated = false,
  });
}

class AIService extends ChangeNotifier {
  final List<Message> _messages = [];
  bool _isLoading = false;
  GenerativeModel? _model;
  ChatSession? _chatSession;

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  void markMessageAsAnimated(int index) {
    if (index >= 0 && index < _messages.length) {
      _messages[index].hasAnimated = true;
      // We don't necessarily need to notifyListeners here as it might trigger a rebuild loop 
      // during the animation itself, but it's safe if handled correctly in the UI.
    }
  }

  // Store closet items to map AI responses back to images
  List<ClothingItem> _closetItems = [];
  final String? _explicitApiKey;
  String? _lastSystemPrompt;

  AIService({String? apiKey}) : _explicitApiKey = apiKey {
    _initModel();
  }

  void _initModel() {
    final apiKey = _explicitApiKey ?? AppConstants.geminiLLMApiKey;
    
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
        final extractionResult = processResponse(responseText);
        _messages.add(Message(
          text: extractionResult.cleanText, 
          isUser: false, 
          imagePaths: extractionResult.imagePaths,
          itemIds: extractionResult.itemIds,
        ));
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
  void updateContext(List<ClothingItem> items, UserProfile userProfile, {String? weatherInfo}) {
    _closetItems = items; // Store items for image lookup
    
    final apiKey = _explicitApiKey ?? AppConstants.geminiLLMApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') return;

    final inventoryString = InventoryFormatter.formatInventory(items);
    final weatherString = weatherInfo ?? "Weather data unavailable.";

    String systemPrompt = AppPrompts.stylistSystemPrompt
        .replaceAll('{{INVENTORY_LIST}}', inventoryString)
        .replaceAll('{{USER_PROFILE}}', userProfile.toAIContextString())
        .replaceAll('{{WEATHER_INFO}}', weatherString);
    
    // If the prompt hasn't changed, don't reset the session
    if (_lastSystemPrompt == systemPrompt) return;
    _lastSystemPrompt = systemPrompt;

    // Preserve history if session exists
    List<Content>? history;
    if (_chatSession != null) {
      history = _chatSession!.history.toList();
    }

    _model = GenerativeModel(
        model: AppConstants.geminiModel,
        apiKey: apiKey,
        systemInstruction: Content.system(systemPrompt),
    );
    
    // Reset chat session with new model/instruction but keep history
    _chatSession = _model!.startChat(history: history);
  }

  /// Processes the response to extract IDs and clean the text.
  @visibleForTesting
  ({String cleanText, List<String> imagePaths, List<String> itemIds}) processResponse(String text) {
    final List<String> paths = [];
    final List<String> ids = [];
    
    // Regex to find <<ID:some_id>>
    final RegExp idRegex = RegExp(r'<<ID:([^>]+)>>');

    // 1. Identify the "What to wear" section to restrict extraction
    String sectionText = text;
    final lowerText = text.toLowerCase();
    // Assumes standard formatting from prompt
    // Use a slightly flexible search in case of minor formatting variations
    int startIndex = lowerText.indexOf('what to wear');
    
    if (startIndex != -1) {
       // Move start index to after the title
       startIndex += 'what to wear'.length;
       
       // Find the end of the section (next bold header starting with **)
       // We look for ** starting after the current section
       int endIndex = text.indexOf('**', startIndex + 5); // +5 to skip potential formatting chars around title
       
       if (endIndex != -1) {
         sectionText = text.substring(startIndex, endIndex);
       } else {
         sectionText = text.substring(startIndex);
       }
    }

    // 2. Extract IDs only from the section text
    final matches = idRegex.allMatches(sectionText);
    for (final match in matches) {
      final id = match.group(1)?.trim();
      if (id != null) {
        // Find item with this ID
        try {
          final item = _closetItems.firstWhere((item) => item.id == id);
          // Avoid duplicates
          if (!paths.contains(item.imagePath)) {
            paths.add(item.imagePath);
            ids.add(item.id);
          }
        } catch (e) {
          // Item not found, ignore
          debugPrint('AI suggested item ID $id which was not found in context.');
        }
      }
    }

    // 3. Clean tags from the ENTIRE text
    String cleanText = text.replaceAll(idRegex, '');

    return (cleanText: cleanText, imagePaths: paths, itemIds: ids);
  }

  /// Resets the chat by clearing messages and starting a new session
  void resetChat() {
    _messages.clear();
        _chatSession = null;
        _lastSystemPrompt = null;
        notifyListeners();
      }
    
      /// Injects a pre-generated response into the chat stream (e.g. from background task)
      void injectBotResponse(String text) {
        // Optionally add a user prompt context if needed, e.g. "Show me my daily outfit"
        // _messages.add(Message(text: "Here is your daily outfit!", isUser: true)); 
        
        final extractionResult = processResponse(text);
        _messages.add(Message(
          text: extractionResult.cleanText,
          isUser: false,
          imagePaths: extractionResult.imagePaths,
          itemIds: extractionResult.itemIds,
        ));
        notifyListeners();
      }
    }
    