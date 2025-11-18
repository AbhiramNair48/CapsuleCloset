import 'package:flutter/material.dart';

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
                  ? Theme.of(context).colorScheme.primary // User message: primary color (blue/pink)
                  : Colors.white, // Bot message: white
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18.0),
                topRight: const Radius.circular(18.0),
                bottomLeft: isUserMessage ? const Radius.circular(18.0) : const Radius.circular(4.0),
                bottomRight: isUserMessage ? const Radius.circular(4.0) : const Radius.circular(18.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isUserMessage
                    ? Theme.of(context).colorScheme.onPrimary // Text for user message
                    : Theme.of(context).colorScheme.onSurface, // Text for bot message
              ),
              softWrap: true, // Enable text wrapping
              overflow: TextOverflow.visible, // Allow text to wrap instead of clipping
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
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Recommended Outfit:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Display outfit images in a column
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling within this list
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                height: 120, // Fixed height for each image
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    imagePaths[index],
                    fit: BoxFit.cover,
                    frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: frame != null ? child : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white,
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
  });

  final TextEditingController textController;
  final VoidCallback onSendMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text input field
          Expanded(
            child: TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'AI Chatbot',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onSubmitted: (value) {
                // Handle sending message when user presses enter
                onSendMessage();
              },
            ),
          ),
          // Send button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
                size: 16.0,
              ),
              onPressed: onSendMessage,
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(0.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AIChatPageState extends State<AIChatPage> {
  // Mock conversation data with messages and optional outfit images
  List<Map<String, dynamic>> messages = [
    {
      "sender": "bot",
      "text": "Welcome! What would you like to wear today?",
    },
    {
      "sender": "user",
      "text": "What should I wear today?",
    },
    {
      "sender": "bot",
      "text": "Based on the current weather of 79 degrees, I have prepared an outfit for you. Let me know if you like it!",
      "images": ["assets/images/clothes/jacket.png", "assets/images/clothes/trousers.png"]
    }
  ];

  // Controller for the text input field
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50, // Using the same pink background as other pages in the app (not the bottom nav bar)
      body: Column(
        children: [
          // Chat messages list with top padding for spacing from app bar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0), // Added top padding
              child: ListView.builder(
                reverse: false, // Keep messages in chronological order
                padding: EdgeInsets.only(bottom: 10), // Add space for input area
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUserMessage = message["sender"] == "user";

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add vertical spacing between messages
                      if (index > 0) // Only add spacing after the first message
                        const SizedBox(height: 12.0), // Vertical spacing between messages
                      // Chat bubble
                      ChatBubble(
                        message: message["text"],
                        isUserMessage: isUserMessage,
                      ),
                      // Show outfit images if this is a bot message with images
                      if (message["sender"] == "bot" && message["images"] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0), // Add spacing above outfit preview
                          child: OutfitPreview(
                            imagePaths: List<String>.from(message["images"]),
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
              onSendMessage: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  // Method to handle sending a new message
  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      // Add the user's message to the messages list
      setState(() {
        messages.add({
          "sender": "user",
          "text": _textController.text.trim(),
        });
      });

      // Clear the input field
      _textController.clear();

      // In a real implementation, this would send the message to the AI
      // and then add the AI's response to the messages list
      // For now, we'll just add a mock response after a delay
      _simulateAIResponse();
    }
  }

  // Simulate an AI response after a short delay
  Future<void> _simulateAIResponse() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Add a mock response from the AI
    setState(() {
      messages.add({
        "sender": "bot",
        "text": "I've analyzed your preferences and the current weather. Here are some recommendations for you!",
        "images": ["assets/images/clothes/jacket.png", "assets/images/clothes/trousers.png"] // Using mock images
      });
    });
  }
}