import 'package:flutter/material.dart';
import '../models/outfit.dart';

/// Widget for displaying an outfit card with a collage of clothing items
class OutfitCard extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback onTap;

  const OutfitCard({
    super.key,
    required this.outfit,
    required this.onTap,
  });

  static const double _cardBorderRadius = 12.0;
  static const double _imageSpacing = 2.0;
  static const double _errorIconSize = 30.0;
  static const int _maxItemsInCollage = 4;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildCollage(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                outfit.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollage() {
    final items = outfit.items;
    final itemCount = items.length;
    final displayCount = itemCount > _maxItemsInCollage ? _maxItemsInCollage : itemCount;

    if (displayCount == 0) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(_cardBorderRadius),
            topRight: Radius.circular(_cardBorderRadius),
          ),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported, size: _errorIconSize),
        ),
      );
    }

    if (displayCount == 1) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(_cardBorderRadius),
          topRight: Radius.circular(_cardBorderRadius),
        ),
        child: _buildImage(items[0].imagePath),
      );
    }

    if (displayCount == 2) {
      return Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_cardBorderRadius),
              ),
              child: _buildImage(items[0].imagePath),
            ),
          ),
          SizedBox(width: _imageSpacing),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(_cardBorderRadius),
              ),
              child: _buildImage(items[1].imagePath),
            ),
          ),
        ],
      );
    }

    if (displayCount == 3) {
      return Column(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(_cardBorderRadius),
                    ),
                    child: _buildImage(items[0].imagePath),
                  ),
                ),
                SizedBox(width: _imageSpacing),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(_cardBorderRadius),
                    ),
                    child: _buildImage(items[1].imagePath),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: _imageSpacing),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(_cardBorderRadius),
                bottomRight: Radius.circular(_cardBorderRadius),
              ),
              child: _buildImage(items[2].imagePath),
            ),
          ),
        ],
      );
    }

    // 4 items - 2x2 grid
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(_cardBorderRadius),
                  ),
                  child: _buildImage(items[0].imagePath),
                ),
              ),
              SizedBox(width: _imageSpacing),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(_cardBorderRadius),
                  ),
                  child: _buildImage(items[1].imagePath),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: _imageSpacing),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: itemCount > _maxItemsInCollage
                      ? BorderRadius.zero
                      : const BorderRadius.only(
                          bottomLeft: Radius.circular(_cardBorderRadius),
                        ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildImage(items[2].imagePath),
                      if (itemCount > _maxItemsInCollage)
                        Container(
                          color: Colors.black54,
                          child: Center(
                            child: Text(
                              '+${itemCount - _maxItemsInCollage}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: _imageSpacing),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(_cardBorderRadius),
                  ),
                  child: _buildImage(items[3].imagePath),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      cacheWidth: 200, // Cache width for better performance
      cacheHeight: 200, // Cache height for better performance
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.image_not_supported,
            size: _errorIconSize,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}

