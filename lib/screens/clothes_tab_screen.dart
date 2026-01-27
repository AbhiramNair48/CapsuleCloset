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
                IconButton.filledTonal(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HamperScreen()),
                    );
                  },
                  icon: const Icon(Icons.local_laundry_service),
                  tooltip: 'Hamper',
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
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (filter == 'All') {
                                _selectedFilter = null;
                                context.read<DataService>().filterClothingItemsByType(null);
                              } else {
                                _selectedFilter = selected ? filter : null;
                                context.read<DataService>().filterClothingItemsByType(_selectedFilter);
                              }
                            });
                          },
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
                  return EmptyStateWidget(
                    icon: Icons.checkroom_outlined,
                    message: 'No clothing items yet',
                    buttonText: 'Add Item',
                    onPressed: () {
                      context.read<NavigationService>().setIndex(2); // Switch to Add tab
                    },
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
