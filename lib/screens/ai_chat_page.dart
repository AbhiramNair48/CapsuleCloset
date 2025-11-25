import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../services/data_service.dart';

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
            child: Text(
              message,
              style: TextStyle(
                color: isUserMessage
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ],
    );
  }
}

/// OutfitPreview widget to display clothing images
/// Shows a list of outfit images in a vertical layout
class OutfitPreview extends StatelessWidget {
  final List<String> imagePaths;

  const OutfitPreview({
    super.key,
    required this.imagePaths,
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

  @override
  void initState() {
    super.initState();
    // Initialize chat with closet context if it's the first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final aiService = context.read<AIService>();
      if (aiService.messages.isEmpty) {
        final dataService = context.read<DataService>();
        aiService.updateContext(dataService.clothingItems);
        aiService.startChat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Consumer<AIService>(
        builder: (context, aiService, child) {
          if (!aiService.hasApiKey) {
            return Center(
              child: Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.vpn_key, size: 48, color: Colors.amber),
                      const SizedBox(height: 16),
                      const Text(
                        'Gemini API Key Required',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please enter your Google Gemini API key to use the AI stylist.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'API Key',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (value) {
                          aiService.setApiKey(value.trim());
                          // Initialize context after setting key
                          final dataService = context.read<DataService>();
                          aiService.updateContext(dataService.clothingItems);
                          aiService.startChat();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Column(
            children: [
              // Chat messages list with top padding for spacing from app bar
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
                  child: ListView.builder(
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