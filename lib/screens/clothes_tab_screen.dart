import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../widgets/closet_content.dart';
import '../widgets/apparel_info_overlay.dart';
import 'delete_clothing_items_screen.dart';
import '../models/clothing_item.dart';

class ClothesTabScreen extends StatelessWidget {
  const ClothesTabScreen({super.key});

  void _showApparelInfo(BuildContext context, ClothingItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ApparelInfoOverlay(
          item: item,
          onClose: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<DataService>(
        builder: (context, dataService, child) {
          return ClosetContent(
            items: dataService.clothingItems,
            onItemTap: (item) => _showApparelInfo(context, item),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DeleteClothingItemsScreen(),
            ),
          );
        },
        child: const Icon(Icons.delete_outline),
      ),
    );
  }
}
