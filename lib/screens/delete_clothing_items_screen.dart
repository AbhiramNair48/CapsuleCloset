import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../widgets/clothing_item_card.dart';

class DeleteClothingItemsScreen extends StatefulWidget {
  const DeleteClothingItemsScreen({super.key});

  @override
  State<DeleteClothingItemsScreen> createState() => _DeleteClothingItemsScreenState();
}

class _DeleteClothingItemsScreenState extends State<DeleteClothingItemsScreen> {
  final Set<String> _selectedItemIds = {};

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedItemIds.contains(id)) {
        _selectedItemIds.remove(id);
      } else {
        _selectedItemIds.add(id);
      }
    });
  }

  void _deleteSelected() {
    if (_selectedItemIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Clothing Items'),
        content: Text('Are you sure you want to delete ${_selectedItemIds.length} item(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final dataService = context.read<DataService>();
              for (final id in _selectedItemIds) {
                dataService.removeClothingItem(id);
              }
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clothing items deleted')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Clothes'),
      ),
      body: Consumer<DataService>(
        builder: (context, dataService, child) {
          final items = dataService.clothingItems;

          if (items.isEmpty) {
            return const Center(
              child: Text('No clothes to delete'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.75,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = _selectedItemIds.contains(item.id);

              return Stack(
                children: [
                  Container(
                    decoration: isSelected
                        ? BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3.0,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          )
                        : null,
                    child: ClothingItemCard(
                      item: item,
                      onTap: () => _toggleSelection(item.id),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: _selectedItemIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _deleteSelected,
              label: Text('Delete (${_selectedItemIds.length})'),
              icon: const Icon(Icons.delete),
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            )
          : null,
    );
  }
}
