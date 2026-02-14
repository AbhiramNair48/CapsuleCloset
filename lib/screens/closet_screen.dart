import 'package:flutter/material.dart';
import 'saved_outfits_screen.dart';
import 'clothes_tab_screen.dart';
import '../widgets/glass_container.dart';
import '../theme/app_design.dart';

/// Main screen widget for displaying the user's digital closet
class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Listen to animation to update tab selection during swipes
    _tabController.animation?.addListener(() {
      final value = _tabController.animation!.value;
      final newIndex = value.round();
      if (newIndex != _currentIndex && !_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    });
    
    // Listen to standard state changes (backup)
    _tabController.addListener(() {
       if (_tabController.indexIsChanging) {
         setState(() {
           _currentIndex = _tabController.index;
         });
       }
    });
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassContainer(
            height: 50,
            borderRadius: BorderRadius.circular(25),
            padding: const EdgeInsets.all(4),
            child: Stack(
              children: [
                // Sliding Highlight
                AnimatedAlign(
                  alignment: _currentIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    heightFactor: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                // Tab Text
                Row(
                  children: [
                    _buildTab('Clothes', 0),
                    _buildTab('Outfits', 1),
                  ],
                ),
              ],
            ),
          ),
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

  Widget _buildTab(String text, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
          _tabController.animateTo(index);
        },
        child: Container(
          color: Colors.transparent, // Hit test target
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
              fontFamily: 'Roboto', // Explicitly set font family if needed, or rely on theme
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}