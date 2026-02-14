import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../widgets/outfit_card.dart';
import '../widgets/generic_delete_screen.dart';
import '../models/outfit.dart';
import '../theme/app_design.dart';

class DeleteOutfitsScreen extends StatelessWidget {
  const DeleteOutfitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        return GenericDeleteScreen<Outfit>(
          title: 'Delete Outfits',
          items: dataService.outfits,
          getId: (item) => item.id,
          emptyMessage: 'No outfits to delete',
          snackBarMessage: 'Outfits deleted',
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.2,
          ),
          onDelete: (ids) {
            for (final id in ids) {
              dataService.removeOutfit(id);
            }
          },
          itemBuilder: (context, item, isSelected, onTap) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppColors.accent : Colors.transparent,
                  width: 3.0,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: OutfitCard(
                key: ValueKey(item.id),
                outfit: item,
                onTap: onTap,
              ),
            );
          },
        );
      },
    );
  }
}
