import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  static const double _errorIconSize = 50.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            SizedBox.expand(
              child: CachedNetworkImage(
                imageUrl: item.imagePath,
                fit: BoxFit.cover,
                memCacheWidth: 300,
                memCacheHeight: 300,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) {
                  return Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported,
                      size: _errorIconSize,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.more_vert),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                ),
                onPressed: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

