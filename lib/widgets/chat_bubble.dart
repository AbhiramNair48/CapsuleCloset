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
          // Replace * with bullet point
          String formattedText = splitText[i].replaceAll('*', '•');
          spans.add(TextSpan(text: formattedText, style: baseStyle));
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
