import 'package:flutter/material.dart';

class DeleteIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final double? size;
  final double iconSize;

  const DeleteIconButton({
    super.key,
    required this.onTap,
    this.size, // If null, container wraps content + padding
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        padding: size == null ? const EdgeInsets.all(6) : null,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            )
          ],
        ),
        child: Center(
          child: Icon(
            Icons.close,
            size: iconSize,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}
