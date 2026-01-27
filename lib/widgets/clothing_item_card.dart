import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/clothing_item.dart';

/// Widget for displaying a clothing item card in the grid with a smooth entry animation
class ClothingItemCard extends StatefulWidget {
  final ClothingItem item;
  final VoidCallback onTap;

  const ClothingItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  State<ClothingItemCard> createState() => _ClothingItemCardState();
}

class _ClothingItemCardState extends State<ClothingItemCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const double _errorIconSize = 50.0;

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = widget.item.imagePath.startsWith('http');
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: widget.onTap,
            child: Stack(
              children: [
                SizedBox.expand(
                  child: isNetworkImage 
                    ? CachedNetworkImage(
                        imageUrl: widget.item.imagePath,
                        fit: BoxFit.cover,
                        memCacheWidth: 300,
                        memCacheHeight: 300,
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
                      )
                    : Image.asset(
                        widget.item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
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
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: widget.onTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}