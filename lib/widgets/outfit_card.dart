import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/outfit.dart';

/// Widget for displaying an outfit card with a collage of clothing items and smooth entry animation
class OutfitCard extends StatefulWidget {
  final Outfit outfit;
  final VoidCallback onTap;

  const OutfitCard({
    super.key,
    required this.outfit,
    required this.onTap,
  });

  @override
  State<OutfitCard> createState() => _OutfitCardState();
}

class _OutfitCardState extends State<OutfitCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const double _imageSpacing = 2.0;
  static const double _errorIconSize = 30.0;
  static const int _maxItemsInCollage = 4;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildCollage(),
                ),
                Container(
                  color: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    widget.outfit.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollage() {
    final items = widget.outfit.items;
    final itemCount = items.length;
    final displayCount = itemCount > _maxItemsInCollage ? _maxItemsInCollage : itemCount;

    if (displayCount == 0) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: _errorIconSize),
        ),
      );
    }

    if (displayCount == 1) {
      return _buildImage(items[0].imagePath);
    }

    if (displayCount == 2) {
      return Row(
        children: [
          Expanded(child: _buildImage(items[0].imagePath)),
          const SizedBox(width: _imageSpacing),
          Expanded(child: _buildImage(items[1].imagePath)),
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
                Expanded(child: _buildImage(items[0].imagePath)),
                const SizedBox(width: _imageSpacing),
                Expanded(child: _buildImage(items[1].imagePath)),
              ],
            ),
          ),
          const SizedBox(height: _imageSpacing),
          Expanded(
            child: _buildImage(items[2].imagePath),
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
              Expanded(child: _buildImage(items[0].imagePath)),
              const SizedBox(width: _imageSpacing),
              Expanded(child: _buildImage(items[1].imagePath)),
            ],
          ),
        ),
        const SizedBox(height: _imageSpacing),
        Expanded(
          child: Row(
            children: [
              Expanded(
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: _imageSpacing),
              Expanded(child: _buildImage(items[3].imagePath)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String imagePath) {
    return CachedNetworkImage(
      imageUrl: imagePath,
      fit: BoxFit.cover,
      memCacheWidth: 200,
      memCacheHeight: 200,
      placeholder: (context, url) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) {
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(
            Icons.image_not_supported,
            size: _errorIconSize,
          ),
        );
      },
    );
  }
}