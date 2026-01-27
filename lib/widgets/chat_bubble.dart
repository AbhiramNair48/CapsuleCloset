import 'package:flutter/material.dart';
import 'typing_text.dart';

/// ChatBubble widget for displaying messages in the chat interface
/// Supports both user and bot messages with different styling and entry animations
class ChatBubble extends StatefulWidget {
  final String message;
  final bool isUserMessage; // true for user, false for bot
  final CrossAxisAlignment alignment;
  final bool shouldAnimate;
  final VoidCallback? onAnimationComplete;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUserMessage,
    this.alignment = CrossAxisAlignment.end,
    this.shouldAnimate = false,
    this.onAnimationComplete,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.shouldAnimate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldAnimate && !oldWidget.shouldAnimate) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Row(
          mainAxisAlignment:
              widget.isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: widget.isUserMessage
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18.0),
                    topRight: const Radius.circular(18.0),
                    bottomLeft: widget.isUserMessage ? const Radius.circular(18.0) : const Radius.circular(4.0),
                    bottomRight: widget.isUserMessage ? const Radius.circular(4.0) : const Radius.circular(18.0),
                  ),
                ),
                child: (!widget.isUserMessage && widget.shouldAnimate)
                    ? TypingText(
                        text: widget.message,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                        onComplete: widget.onAnimationComplete,
                      )
                    : _buildFormattedText(widget.message, context, widget.isUserMessage),
              ),
            ),
          ],
        ),
      ),
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