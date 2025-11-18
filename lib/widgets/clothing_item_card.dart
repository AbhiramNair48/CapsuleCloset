import 'package:flutter/material.dart';
import '../models/clothing_item.dart';

/// Widget for displaying a clothing item card in the grid
class ClothingItemCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onTap;

  const ClothingItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  static const double _cardBorderRadius = 12.0;
  static const double _iconButtonPadding = 8.0;
  static const double _errorIconSize = 50.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_cardBorderRadius),
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              cacheWidth: 300, // Cache width for better performance
              cacheHeight: 300, // Cache height for better performance
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: _errorIconSize,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: _iconButtonPadding,
            right: _iconButtonPadding,
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black54),
              onPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

