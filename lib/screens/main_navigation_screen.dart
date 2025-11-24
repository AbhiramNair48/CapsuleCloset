import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ai_chat_page.dart'; // Home tab
import 'closet_screen.dart'; // Closet tab
import 'friends_page.dart'; // Friends tab
import 'upload_to_closet_page.dart'; // Add tab
import '../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

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

  int _selectedIndex = _homeTabIndex; // Start with Home tab

  void _onItemTapped(int index) {
    if (index == _settingsTabIndex) {
      _showSettingsDialog();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
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

  Widget _getCurrentBody() {
    switch (_selectedIndex) {
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
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Capsule Closet',
          style: GoogleFonts.dancingScript(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 247, 35, 20), // Red
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
            icon: Icon(Icons.chat),
            label: 'Chat',
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