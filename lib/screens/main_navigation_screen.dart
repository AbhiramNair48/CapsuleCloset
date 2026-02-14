import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'ai_chat_page.dart'; // Home tab
import 'closet_screen.dart'; // Closet tab
import 'friends_page.dart'; // Friends tab
import 'upload_to_closet_page.dart'; // Add tab
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/glass_container.dart';
import '../theme/app_design.dart';
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

  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    // Defer listener registration
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<NavigationService>().addListener(_onNavigationChange);
    });
  }

  @override
  void dispose() {
    context.read<NavigationService>().removeListener(_onNavigationChange);
    _pageController?.dispose();
    super.dispose();
  }

  PageController get _controller {
    // Lazy initialization to handle hot reload cases where initState didn't run for this field
    _pageController ??= PageController(initialPage: context.read<NavigationService>().selectedIndex);
    return _pageController!;
  }

  void _onNavigationChange() {
    final newIndex = context.read<NavigationService>().selectedIndex;
    if (_controller.hasClients && _controller.page?.round() != newIndex) {
       _controller.animateToPage(
         newIndex, 
         duration: const Duration(milliseconds: 400), 
         curve: Curves.easeInOut
       );
    }
  }

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
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text('Settings', style: AppText.header),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.white),
                title: Text('Profile', style: AppText.body),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const ProfileScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        return SlideTransition(position: animation.drive(tween), child: FadeTransition(opacity: animation, child: child));
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined, color: Colors.white),
                title: Text('Notifications', style: AppText.body),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to notifications screen
                },
              ),
              const Divider(color: Colors.white24),
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

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<NavigationService>().selectedIndex;

    return GlassScaffold(
      // AppBar removed to clear the constant header
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe to change tabs (handled by nav bar)
        children: const [
          AIChatPage(),
          ClosetScreen(),
          UploadToClosetPage(),
          FriendsPage(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
        child: GlassContainer(
          height: 70,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          blur: 20,
          color: AppColors.glassFill.withValues(alpha: 0.1), // Slightly darker for contrast
          child: Row(
            children: [
              Expanded(child: _buildNavItem(CupertinoIcons.home, "Chat", _homeTabIndex, selectedIndex)),
              Expanded(child: _buildNavItem(CupertinoIcons.collections, "Closet", _closetTabIndex, selectedIndex)),
              Expanded(child: _buildNavItem(CupertinoIcons.add_circled, "Upload", _addTabIndex, selectedIndex)),
              Expanded(child: _buildNavItem(CupertinoIcons.group, "Friends", _friendsTabIndex, selectedIndex)),
              Expanded(child: _buildNavItem(CupertinoIcons.settings, "Settings", _settingsTabIndex, selectedIndex)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, int selectedIndex) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.accent : Colors.white,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppText.label.copyWith(
              color: isSelected ? AppColors.accent : Colors.white60,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

  