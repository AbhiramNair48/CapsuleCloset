import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../services/data_service.dart';
import '../models/outfit.dart';
import '../services/weather_service.dart';

/// ChatBubble widget for displaying messages in the chat interface
/// Supports both user and bot messages with different styling
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUserMessage; // true for user, false for bot
  final CrossAxisAlignment alignment;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUserMessage,
    this.alignment = CrossAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisAlignment:
          isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isUserMessage
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18.0),
                topRight: const Radius.circular(18.0),
                bottomLeft: isUserMessage ? const Radius.circular(18.0) : const Radius.circular(4.0),
                bottomRight: isUserMessage ? const Radius.circular(4.0) : const Radius.circular(18.0),
              ),
            ),
            child: _buildFormattedText(message, context, isUserMessage),
          ),
        ),
      ],
    );
  }

  Widget _buildFormattedText(String text, BuildContext context, bool isUserMessage) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseStyle = TextStyle(
      color: isUserMessage
          ? colorScheme.onPrimaryContainer
          : colorScheme.onSurfaceVariant,
    );
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);

    List<InlineSpan> spans = [];
    final splitText = text.split('**');

    for (int i = 0; i < splitText.length; i++) {
      if (i % 2 == 1) {
        // Bold text
        spans.add(TextSpan(text: splitText[i], style: boldStyle));
      } else {
        // Normal text
        if (splitText[i].isNotEmpty) {
          spans.add(TextSpan(text: splitText[i], style: baseStyle));
        }
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      softWrap: true,
      overflow: TextOverflow.visible,
    );
  }
}

/// OutfitPreview widget to display clothing images
/// Shows a list of outfit images in a vertical layout
class OutfitPreview extends StatelessWidget {
  final List<String> imagePaths;
  final List<String> itemIds;

  const OutfitPreview({
    super.key,
    required this.imagePaths,
    this.itemIds = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header for outfit preview
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Recommended Outfit:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          // Display outfit images in a column
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling within this list
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              return Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 175, // Limit the height to prevent very tall images
                  ),
                  width: double.infinity,
                  child: Image.asset(
                    imagePaths[index],
                    fit: BoxFit.contain,
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return const SizedBox(
                        height: 100,
                        child: Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          if (itemIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final dataService = context.read<DataService>();
                    final items = dataService.clothingItems
                        .where((item) => itemIds.contains(item.id))
                        .toList();

                    if (items.isNotEmpty) {
                      final now = DateTime.now();
                      final newOutfit = Outfit(
                        id: now.millisecondsSinceEpoch.toString(),
                        name: "${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.year}",
                        items: items,
                        savedDate: now,
                      );
                      dataService.addOutfit(newOutfit);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Outfit saved to closet!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not find these items in your closet.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.checkroom),
                  label: const Text('Save Outfit'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
      _initializeChatWithWeather();
    });
  }

  Future<void> _initializeChatWithWeather() async {
    if (_aiService.messages.isEmpty) {
      final dataService = context.read<DataService>();
      String? weatherString;

      try {
        final weatherService = WeatherService();
        final weatherData = await weatherService.getCurrentWeather();
        if (weatherData.isNotEmpty) {
           weatherString = 
            "Temp: ${weatherData['current_temp']}${weatherData['unit']}, "
            "Max: ${weatherData['max_temp']}${weatherData['unit']}, "
            "Precip: ${weatherData['precip_chance']}%";
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