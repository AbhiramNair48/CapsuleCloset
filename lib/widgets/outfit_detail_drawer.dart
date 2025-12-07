import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../models/clothing_item.dart';
import 'clothing_item_card.dart';
import 'apparel_info_overlay.dart';

/// Widget for displaying outfit details in a bottom sheet drawer
class OutfitDetailDrawer extends StatefulWidget {
  final Outfit outfit;
  final Function(Outfit) onOutfitUpdated;

  const OutfitDetailDrawer({
    super.key,
    required this.outfit,
    required this.onOutfitUpdated,
  });

  @override
  State<OutfitDetailDrawer> createState() => OutfitDetailDrawerState();
}

class OutfitDetailDrawerState extends State<OutfitDetailDrawer> {
  late TextEditingController _nameController;
  late Outfit _currentOutfit;
  bool _isEditingName = false;

  static const double _borderRadius = 16.0;
  static const double _padding = 24.0;
  static const double _spacing = 16.0;
  static const double _initialChildSize = 0.9;
  static const double _minChildSize = 0.5;
  static const double _maxChildSize = 0.95;

  @override
  void initState() {
    super.initState();
    _currentOutfit = widget.outfit;
    _nameController = TextEditingController(text: _currentOutfit.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() {
    if (_nameController.text.trim().isNotEmpty) {
      final updatedOutfit = _currentOutfit.copyWith(name: _nameController.text.trim());
      widget.onOutfitUpdated(updatedOutfit);
      setState(() {
        _currentOutfit = updatedOutfit;
        _isEditingName = false;
      });
    }
  }

  void _cancelEdit() {
    _nameController.text = _currentOutfit.name;
    setState(() {
      _isEditingName = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_borderRadius),
          topRight: Radius.circular(_borderRadius),
        ),
      ),
      padding: const EdgeInsets.all(_padding),
      margin: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: _initialChildSize,
        minChildSize: _minChildSize,
        maxChildSize: _maxChildSize,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _isEditingName
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _nameController,
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                                          border: OutlineInputBorder(),
                                        ),
                                        autofocus: true,
                                        onSubmitted: (_) => _saveName(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.check, color: Theme.of(context).colorScheme.tertiary),
                                      onPressed: _saveName,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
                                      onPressed: _cancelEdit,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                )
                              : Text(
                                  _currentOutfit.name,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                          const SizedBox(height: 4),
                          Text(
                            'Saved ${_formatDate(_currentOutfit.savedDate)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isEditingName)
                      Transform.translate(
                        offset: const Offset(0, -7),
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            setState(() {
                              _isEditingName = true;
                            });
                          },
                          tooltip: 'Edit name',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: _spacing),
                const Divider(),
                const SizedBox(height: _spacing),
                
                // Outfit items title
                Text(
                  'Items in this outfit (${_currentOutfit.items.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: _spacing),
                
                // Outfit items grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _currentOutfit.items.length,
                  itemBuilder: (context, index) {
                    return ClothingItemCard(
                      item: _currentOutfit.items[index],
                      onTap: () => _showApparelInfo(context, _currentOutfit.items[index]),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    }
  }
}

