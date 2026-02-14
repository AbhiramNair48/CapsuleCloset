import 'package:flutter/material.dart';
import '../theme/app_design.dart';
import 'glass_container.dart';
import 'typing_text.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool isUserMessage;
  final bool shouldAnimate;
  final VoidCallback? onAnimationComplete;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUserMessage,
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
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    if (widget.shouldAnimate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // User Message: Solid Accent Color or Dark Glass
    // Bot Message: Glass with Border
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Align(
          alignment: widget.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: widget.isUserMessage 
              ? _buildUserBubble()
              : _buildBotBubble(),
          ),
        ),
      ),
    );
  }

  Widget _buildUserBubble() {
    // User bubble is simpler, maybe just a text on right
    final baseStyle = AppText.body.copyWith(color: Colors.black87, fontWeight: FontWeight.w500);
    
    return Container(
       constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
       decoration: BoxDecoration(
         color: AppColors.accent,
         borderRadius: const BorderRadius.only(
           topLeft: Radius.circular(24),
           topRight: Radius.circular(24),
           bottomLeft: Radius.circular(24),
           bottomRight: Radius.circular(4), // Tail
         ),
         boxShadow: [
           BoxShadow(
             color: AppColors.accent.withValues(alpha: 0.2),
             blurRadius: 10,
             offset: const Offset(0, 4),
           )
         ]
       ),
       child: _buildFormattedText(widget.message, baseStyle),
    );
  }

  Widget _buildBotBubble() {
    return GlassContainer(
      width: MediaQuery.of(context).size.width * 0.8,
      borderRadius: const BorderRadius.only(
           topLeft: Radius.circular(24),
           topRight: Radius.circular(24),
           bottomRight: Radius.circular(24),
           bottomLeft: Radius.circular(4), // Tail
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: widget.shouldAnimate
          ? TypingText(
              text: widget.message,
              style: AppText.body,
              onComplete: widget.onAnimationComplete,
            )
          : _buildFormattedText(widget.message, AppText.body),
    );
  }

  Widget _buildFormattedText(String text, TextStyle baseStyle) {
    // Make bold text extra prominent
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.w900);

    List<InlineSpan> spans = [];
    
    // Split by lines to handle bullet points first
    final lines = text.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      if (line.trim().startsWith('* ')) {
        line = line.replaceFirst('* ', '• ');
      }
      
      // Process bold formatting within the line
      final splitText = line.split('**');
      for (int j = 0; j < splitText.length; j++) {
        if (j % 2 == 1) {
          // Bold text
          spans.add(TextSpan(text: splitText[j], style: boldStyle));
        } else {
          // Normal text
          if (splitText[j].isNotEmpty) {
            spans.add(TextSpan(text: splitText[j], style: baseStyle));
          }
        }
      }
      
      // Add newline if it's not the last line
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
