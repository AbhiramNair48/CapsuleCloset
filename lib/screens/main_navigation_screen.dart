import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ai_chat_page.dart'; // Home tab
import 'closet_screen.dart'; // Closet tab
import 'friends_page.dart'; // Friends tab
import 'upload_to_closet_page.dart'; // Add tab
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import 'profile_screen.dart';

/// Main navigation screen that handles bottom navigation
/// This separates navigation logic from content screens
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  static const int _homeTabIndex = 0;
  static const int _closetTabIndex = 1;
  static const int _addTabIndex = 2;
  static const int _friendsTabIndex = 3;
  static const int _settingsTabIndex = 4;

  void _onItemTapped(int index) {
    if (index == _settingsTabIndex) {
      _showSettingsDialog();
      return;
    }
    context.read<NavigationService>().setIndex(index);
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
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
                leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                title: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () {
                  Navigator.pop(context);
                  context.read<AuthService>().logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getCurrentBody(int selectedIndex) {
    switch (selectedIndex) {
      case _homeTabIndex:
        return const AIChatPage();
      case _closetTabIndex:
        return const ClosetScreen();
      case _addTabIndex:
        return const UploadToClosetPage();
      case _friendsTabIndex:
        return const FriendsPage();
      case _settingsTabIndex:
        _showSettingsDialog();
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

    @override

    Widget build(BuildContext context) {
      final selectedIndex = context.watch<NavigationService>().selectedIndex;

      return Scaffold(

        // Background color is handled by the theme's scaffoldBackgroundColor

        appBar: AppBar(

          title: const Text('Capsule Closet'),

          // AppBar styles are now handled by the theme

        ),

        body: _getCurrentBody(selectedIndex),

        bottomNavigationBar: NavigationBar(

          selectedIndex: selectedIndex,

          onDestinationSelected: _onItemTapped,

          destinations: const [

            NavigationDestination(

              icon: Icon(Icons.chat_outlined),

              selectedIcon: Icon(Icons.chat),

              label: 'Chat',

            ),

            NavigationDestination(

              icon: Icon(Icons.checkroom_outlined),

              selectedIcon: Icon(Icons.checkroom),

              label: 'Closet',

            ),

            NavigationDestination(

              icon: Icon(Icons.add_circle_outline),

              selectedIcon: Icon(Icons.add_circle),

              label: 'Add',

            ),

            NavigationDestination(

              icon: Icon(Icons.group_outlined),

              selectedIcon: Icon(Icons.group),

              label: 'Friends',

            ),

            NavigationDestination(

              icon: Icon(Icons.settings_outlined),

              selectedIcon: Icon(Icons.settings),

              label: 'Settings',

            ),

          ],

        ),

      );

    }

  }

  