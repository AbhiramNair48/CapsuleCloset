import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import 'clothing_item_card.dart';

/// Widget for displaying the closet grid content
class ClosetContent extends StatelessWidget {
  final Function(ClothingItem) onItemTap;
  final List<ClothingItem> items;

  const ClosetContent({
    super.key,
    required this.onItemTap,
    required this.items,
  });

  static const double _gridPadding = 16.0;
  static const int _gridCrossAxisCount = 2;
  static const double _gridSpacing = 16.0;
  static const double _gridAspectRatio = 0.8;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_gridPadding),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridCrossAxisCount,
          crossAxisSpacing: _gridSpacing,
          mainAxisSpacing: _gridSpacing,
          childAspectRatio: _gridAspectRatio,
        ),
        itemCount: items.length,
        cacheExtent: 1000, // Increase cache extent to preload more items
        itemBuilder: (context, index) {
          final item = items[index];
          return ClothingItemCard(
            key: ValueKey(item.id), // Add key for better performance
            item: item,
            onTap: () => onItemTap(item),
          );
        },
      ),
    );
  }
}