import 'package:flutter/material.dart';
import 'saved_outfits_screen.dart';
import 'clothes_tab_screen.dart';

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
              const ClothesTabScreen(),
              const SavedOutfitsScreen(),
            ],
          ),
        ),
      ],
    );
  }
}