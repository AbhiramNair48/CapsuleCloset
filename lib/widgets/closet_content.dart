import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../data/mock_clothing_data.dart';
import 'clothing_item_card.dart';

/// Widget for displaying the closet grid content
class ClosetContent extends StatelessWidget {
  final Function(ClothingItem) onItemTap;

  const ClosetContent({
    super.key,
    required this.onItemTap,
  });

  static const double _gridPadding = 16.0;
  static const int _gridCrossAxisCount = 2;
  static const double _gridSpacing = 16.0;
  static const double _gridAspectRatio = 0.8;

  @override
  Widget build(BuildContext context) {
    final items = MockClothingData.items;

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
        itemBuilder: (context, index) {
          return ClothingItemCard(
            item: items[index],
            onTap: () => onItemTap(items[index]),
          );
        },
      ),
    );
  }
}

