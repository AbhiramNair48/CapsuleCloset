import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../services/data_service.dart';
import '../widgets/apparel_info_overlay.dart';
import '../widgets/closet_content.dart';
import 'saved_outfits_screen.dart';

/// Main screen widget for displaying the user's digital closet
class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  void _showApparelInfo(ClothingItem item) {
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
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Clothes'),
            Tab(text: 'Outfits'),
          ],
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black87,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              Consumer<DataService>(
                builder: (context, dataService, child) {
                  return ClosetContent(
                    items: dataService.clothingItems,
                    onItemTap: _showApparelInfo,
                  );
                },
              ),
              const SavedOutfitsScreen(),
            ],
          ),
        ),
      ],
    );
  }
}