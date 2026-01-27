import 'package:flutter/material.dart';

/// A widget that displays text with a typewriter animation.
class TypingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration durationPerChar;
  final VoidCallback? onComplete;

  const TypingText({
    super.key,
    required this.text,
    this.style,
    this.durationPerChar = const Duration(milliseconds: 5),
    this.onComplete,
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();
    final duration = widget.durationPerChar * widget.text.length;
    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );

    _characterCount = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void didUpdateWidget(TypingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      final duration = widget.durationPerChar * widget.text.length;
      _controller.duration = duration;
      _characterCount = StepTween(
        begin: 0,
        end: widget.text.length,
      ).animate(_controller);
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
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        final textToShow = widget.text.substring(0, _characterCount.value);
        return _buildFormattedText(textToShow, context);
      },
    );
  }

  Widget _buildFormattedText(String text, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseStyle = widget.style ?? TextStyle(
      color: colorScheme.onSurfaceVariant,
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
