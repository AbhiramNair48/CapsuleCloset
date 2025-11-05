import 'package:flutter/material.dart';
import 'models/clothing_item.dart';
import 'widgets/apparel_info_overlay.dart';
import 'widgets/closet_content.dart';
import 'screens/saved_outfits_screen.dart';
import 'screens/friends_page.dart';

/// Main screen widget for displaying the user's digital closet
class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  _ClosetScreenState createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> with SingleTickerProviderStateMixin {
  static const int _initialSelectedIndex = 1; // Start with Closet tab
  static const int _homeTabIndex = 0;
  static const int _closetTabIndex = 1;
  static const int _addTabIndex = 2;
  static const int _friendsTabIndex = 3;
  static const int _settingsTabIndex = 4;

  int _selectedIndex = _initialSelectedIndex;
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

  void _onItemTapped(int index) {
    if (index == _addTabIndex) {
      _showAddClothingDialog();
      return;
    }
    if (index == _settingsTabIndex) {
      _showSettingsDialog();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showUnderDevelopmentDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(feature),
          content: const Text('This feature will be implemented soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAddClothingDialog() {
    _showUnderDevelopmentDialog('Add New Item');
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to profile screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notifications'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to notifications screen
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        );
      },
    );
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

  Widget _getCurrentBody() {
    switch (_selectedIndex) {
      case _closetTabIndex:
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
                  ClosetContent(
                    onItemTap: _showApparelInfo,
                  ),
                  const SavedOutfitsScreen(),
                ],
              ),
            ),
          ],
        );
      case _friendsTabIndex:
        return const FriendsPage();
      case _addTabIndex:
        _showAddClothingDialog();
        return const SizedBox.shrink();
      case _homeTabIndex:
        return Center(
          child: Text(
            'Home',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
      case _settingsTabIndex:
        _showSettingsDialog();
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Your Digital Closet',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
      ),
      body: _getCurrentBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: 'Closet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
