import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capsule_closet_app/services/background_service.dart';
import '../services/ai_service.dart';
import '../services/data_service.dart';
import '../services/weather_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/outfit_preview.dart';
import '../widgets/weather_module.dart';

/// AI Chatbot Outfit Recommendation Screen
/// Implements the chat interface for getting outfit recommendations from an AI assistant
class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

// Input area widget for the AI chat page
class _InputArea extends StatelessWidget {
  const _InputArea({
    required this.textController,
    required this.onSendMessage,
    required this.isLoading,
  });

  final TextEditingController textController;
  final VoidCallback onSendMessage;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Ask for advice...',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onSubmitted: isLoading ? null : (value) => onSendMessage(),
              enabled: !isLoading,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: isLoading ? null : onSendMessage,
            elevation: 2,
            mini: true,
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class _AIChatPageState extends State<AIChatPage> {
  // Controller for the text input field
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // Add ScrollController
  late AIService _aiService;

  @override
  void initState() {
    super.initState();
    // Initialize chat with closet context if it's the first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aiService = context.read<AIService>();
      // Listen for changes in messages and scroll to bottom
      _aiService.addListener(_scrollDown);
      _initializeChatWithWeather().then((_) => _checkForDailyOutfit());
    });
  }

  Future<void> _checkForDailyOutfit() async {
     try {
       final prefs = await SharedPreferences.getInstance();
       final dailyOutfitText = prefs.getString(keyDailyOutfitReady);
       
       if (dailyOutfitText != null && dailyOutfitText.isNotEmpty) {
         // Consume the outfit (remove from storage)
         await prefs.remove(keyDailyOutfitReady);
         
         if (mounted) {
             _aiService.injectBotResponse(dailyOutfitText);
         }
       }
     } catch (e) {
       debugPrint('Error checking daily outfit: $e');
     }
  }

  Future<void> _initializeChatWithWeather() async {
    final dataService = context.read<DataService>();
    String? weatherString;

    try {
      final weatherService = context.read<WeatherService>();
      final weatherData = await weatherService.getCurrentWeather();
      if (weatherData.isNotEmpty) {
          weatherString =
          "Temp: ${weatherData['current_temp']}${weatherData['unit']}, "
          "Hi: ${weatherData['max_temp']}${weatherData['unit']}, "
          "Lo: ${weatherData['min_temp']}${weatherData['unit']}, "
          "Precip: ${weatherData['precip_chance']}%, "
          "Weather Code: ${weatherData['daily_weather_code']}";
      }
    } catch (e) {
      debugPrint("Weather fetch failed: $e");
    }

    if (!mounted) return;

    _aiService.updateContext(
      dataService.clothingItems,
      dataService.userProfile,
      weatherInfo: weatherString
    );
    _aiService.startChat();
  }

  void _resetChat() {
    _aiService.resetChat(); // Assuming AIService has a reset method
    _textController.clear();
    _initializeChatWithWeather(); // Re-initialize the context with weather data
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-acquire reference if dependencies change, though usually handled in initState/build
    // _aiService = context.read<AIService>(); // Removed to avoid overwriting and potentially losing the listener reference logic
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose controller to avoid memory leaks
    try {
      _aiService.removeListener(_scrollDown); // Remove listener
    } catch (e) {
      // Ignore if aiService was not initialized
    }
    super.dispose();
  }

  void _scrollDown() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button since it's usually not needed for main chat page
        actions: [
          // Weather module
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: WeatherModule(),
          ),
          // New Chat button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: const Icon(Icons.add_comment),
              onPressed: _resetChat,
              tooltip: 'New Chat',
            ),
          ),
        ],
      ),
      body: Consumer<AIService>(
        builder: (context, aiService, child) {
          return Column(
            children: [
              // Chat messages list with top padding for spacing from app bar
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
                  child: ListView.builder(
                    controller: _scrollController, // Assign the controller
                    reverse: false, // Keep messages in chronological order
                    padding: const EdgeInsets.only(bottom: 10), // Add space for input area
                    itemCount: aiService.messages.length,
                    itemBuilder: (context, index) {
                      final message = aiService.messages[index];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Add vertical spacing between messages
                          if (index > 0)
                            const SizedBox(height: 12.0),
                          // Chat bubble
                          ChatBubble(
                            message: message.text,
                            isUserMessage: message.isUser,
                          ),
                          // Show outfit images if this is a bot message with images
                          if (!message.isUser && message.imagePaths != null && message.imagePaths!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: OutfitPreview(
                                imagePaths: message.imagePaths!,
                                itemIds: message.itemIds ?? [],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              // Input area with text field and send button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _InputArea(
                  textController: _textController,
                  onSendMessage: () => _sendMessage(aiService),
                  isLoading: aiService.isLoading,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Method to handle sending a new message
  void _sendMessage(AIService aiService) {
    if (_textController.text.trim().isNotEmpty) {
      final text = _textController.text.trim();
      _textController.clear();
      aiService.sendMessage(text);
    }
  }
}