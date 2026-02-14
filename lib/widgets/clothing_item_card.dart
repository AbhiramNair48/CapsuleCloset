import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/clothing_item.dart';
import 'glass_container.dart';

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
        child: GestureDetector(
          onTap: widget.onTap,
          child: GlassContainer(
            borderRadius: BorderRadius.circular(12),
            padding: EdgeInsets.zero, // Important for image to fill
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
                          color: Colors.white10,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                        ),
                        errorWidget: (context, url, error) {
                          return Container(
                            color: Colors.white10,
                            child: Icon(
                              Icons.image_not_supported,
                              size: _errorIconSize,
                              color: Colors.white54,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        widget.item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white10,
                            child: Icon(
                              Icons.image_not_supported,
                              size: _errorIconSize,
                              color: Colors.white54,
                            ),
                          );
                        },
                      ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GlassContainer(
                    width: 32,
                    height: 32,
                    borderRadius: BorderRadius.circular(16),
                    blur: 10,
                    color: Colors.black.withValues(alpha: 0.4),
                    padding: EdgeInsets.zero,
                    child: IconButton(
                      icon: const Icon(Icons.more_vert, size: 18),
                      padding: EdgeInsets.zero,
                      color: Colors.white,
                      onPressed: widget.onTap,
                    ),
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