import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../widgets/outfit_card.dart';

class DeleteOutfitsScreen extends StatefulWidget {
  const DeleteOutfitsScreen({super.key});

  @override
  State<DeleteOutfitsScreen> createState() => _DeleteOutfitsScreenState();
}

class _DeleteOutfitsScreenState extends State<DeleteOutfitsScreen> {
  final Set<String> _selectedOutfitIds = {};

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedOutfitIds.contains(id)) {
        _selectedOutfitIds.remove(id);
      } else {
        _selectedOutfitIds.add(id);
      }
    });
  }

  void _deleteSelected() {
    if (_selectedOutfitIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Outfits'),
        content: Text('Are you sure you want to delete ${_selectedOutfitIds.length} outfit(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final dataService = context.read<DataService>();
              for (final id in _selectedOutfitIds) {
                dataService.removeOutfit(id);
              }
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Outfits deleted')),
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
        title: const Text('Delete Outfits'),
      ),
      body: Consumer<DataService>(
        builder: (context, dataService, child) {
          final outfits = dataService.outfits;

          if (outfits.isEmpty) {
            return const Center(
              child: Text('No outfits to delete'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.2,
            ),
            itemCount: outfits.length,
            itemBuilder: (context, index) {
              final outfit = outfits[index];
              final isSelected = _selectedOutfitIds.contains(outfit.id);

              return Stack(
                children: [
                  Container(
                    decoration: isSelected
                        ? BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3.0,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: OutfitCard(
                      outfit: outfit,
                      onTap: () => _toggleSelection(outfit.id),
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
      floatingActionButton: _selectedOutfitIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _deleteSelected,
              label: Text('Delete (${_selectedOutfitIds.length})'),
              icon: const Icon(Icons.delete),
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            )
          : null,
    );
  }
}
