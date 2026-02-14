import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../widgets/clothing_item_card.dart';
import '../widgets/generic_delete_screen.dart';
import '../models/clothing_item.dart';
import '../theme/app_design.dart';

class DeleteClothingItemsScreen extends StatelessWidget {
  const DeleteClothingItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        return GenericDeleteScreen<ClothingItem>(
          title: 'Delete Clothes',
          items: dataService.clothingItems,
          getId: (item) => item.id,
          emptyMessage: 'No clothes to delete',
          snackBarMessage: 'Clothing items deleted',
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.75,
          ),
          onDelete: (ids) {
            for (final id in ids) {
              dataService.removeClothingItem(id);
            }
          },
          itemBuilder: (context, item, isSelected, onTap) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppColors.accent : Colors.transparent,
                  width: 3.0,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClothingItemCard(
                key: ValueKey(item.id),
                item: item,
                onTap: onTap,
              ),
            );
          },
        );
      },
    );
  }
}
