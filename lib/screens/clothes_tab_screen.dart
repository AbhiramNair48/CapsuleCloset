import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../widgets/closet_content.dart';
import '../widgets/apparel_info_overlay.dart';
import '../widgets/empty_state_widget.dart';
import 'delete_clothing_items_screen.dart';
import 'hamper_screen.dart';
import '../models/clothing_item.dart';
import '../services/navigation_service.dart';
import '../widgets/glass_container.dart';
import '../theme/app_design.dart';

class ClothesTabScreen extends StatefulWidget {
  const ClothesTabScreen({super.key});

  @override
  State<ClothesTabScreen> createState() => _ClothesTabScreenState();
}

class _ClothesTabScreenState extends State<ClothesTabScreen> {
  String? _selectedFilter;

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
    // Watch DataService to rebuild when items change
    final dataService = context.watch<DataService>();
    
    // Compute dynamic filters from clean items
    final availableTypes = dataService.clothingItems
        .where((item) => item.isClean)
        .map((item) => item.type)
        .toSet()
        .toList()
      ..sort();
      
    final filters = ['All', ...availableTypes];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Filter Carousel and Hamper Button
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const HamperScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0); // Slide up
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: FadeTransition(opacity: animation, child: child),
                          );
                        },
                      ),
                    );
                  },
                  child: GlassContainer(
                    width: 44,
                    height: 44,
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.glassFill.withValues(alpha: 0.1),
                    child: const Icon(Icons.local_laundry_service, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    itemBuilder: (context, index) {
                      final filter = filters[index];
                      final isSelected = _selectedFilter == filter || (_selectedFilter == null && filter == 'All');
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (filter == 'All') {
                                _selectedFilter = null;
                                context.read<DataService>().filterClothingItemsByType(null);
                              } else {
                                _selectedFilter = isSelected ? null : filter; // Toggle off if already selected unless it's 'All' switching
                                if (_selectedFilter == null) {
                                   context.read<DataService>().filterClothingItemsByType(null);
                                } else {
                                   context.read<DataService>().filterClothingItemsByType(_selectedFilter);
                                }
                              }
                            });
                          },
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            borderRadius: BorderRadius.circular(20),
                            color: isSelected 
                                ? AppColors.accent.withValues(alpha: 0.3) 
                                : AppColors.glassFill.withValues(alpha: 0.1),
                            border: Border.all(
                              color: isSelected ? AppColors.accent : Colors.white24,
                            ),
                            child: Center(
                              child: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (dataService.clothingItems.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 200.0), // Further adjusted for visual center
                    child: EmptyStateWidget(
                      icon: Icons.checkroom_outlined,
                      message: '', 
                      buttonText: 'Add Your First Item!',
                      onPressed: () {
                        context.read<NavigationService>().setIndex(2); 
                      },
                    ),
                  );
                }
                
                // Use filtered items, but if empty after filter, show empty state for filter
                if (dataService.filteredClothingItems.isEmpty && dataService.clothingItems.isNotEmpty) {
                   return const Center(child: Text("No items match this filter."));
                }

                return ClosetContent(
                  items: dataService.filteredClothingItems,
                  onItemTap: (item) => _showApparelInfo(context, item),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0), // Lift above custom nav bar
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const DeleteClothingItemsScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0); // Slide up
                  const end = Offset.zero;
                  const curve = Curves.ease;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
              ),
            );
          },
          child: GlassContainer(
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(28),
            blur: 20,
            color: AppColors.glassFill.withValues(alpha: 0.2),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
