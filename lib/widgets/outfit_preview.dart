import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/outfit.dart';

/// OutfitPreview widget to display clothing images
/// Shows a list of outfit images in a vertical layout
class OutfitPreview extends StatefulWidget {
  final List<String> imagePaths;
  final List<String> itemIds;

  const OutfitPreview({
    super.key,
    required this.imagePaths,
    this.itemIds = const [],
  });

  @override
  State<OutfitPreview> createState() => _OutfitPreviewState();
}

class _OutfitPreviewState extends State<OutfitPreview> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
      decoration: _isSelected ? BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ) : null,
      padding: _isSelected ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header for outfit preview
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Recommended Outfit:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          // Display outfit images in a column
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling within this list
            itemCount: widget.imagePaths.length,
            itemBuilder: (context, index) {
              final imagePath = widget.imagePaths[index];
              final isNetworkImage = imagePath.startsWith('http');
              final itemId = widget.itemIds.length > index ? widget.itemIds[index] : null;

              // Fetch item details if selected to show more info
              String? itemDescription;
               if (_isSelected && itemId != null) {
                  final dataService = context.read<DataService>();
                   try {
                     final item = dataService.clothingItems.firstWhere((i) => i.id == itemId);
                     itemDescription = "${item.type} - ${item.color}";
                   } catch (_) {}
               }


              return Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 175, // Limit the height to prevent very tall images
                      ),
                      width: double.infinity,
                      child: isNetworkImage
                          ? CachedNetworkImage(
                              imageUrl: imagePath,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const SizedBox(
                                height: 100,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (BuildContext context, String url, dynamic error) {
                                return const SizedBox(
                                  height: 100,
                                  child: Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  height: 100,
                                  child: Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                );
                              },
                            ),
                    ),
                    if (_isSelected && itemDescription != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(itemDescription, style: Theme.of(context).textTheme.bodyMedium),
                      ),
                  ],
                ),
              );
            },
          ),
          if (widget.itemIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: _isSelected 
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final dataService = context.read<DataService>();
                                  final items = dataService.clothingItems
                                      .where((item) => widget.itemIds.contains(item.id))
                                      .toList();

                                  if (items.isNotEmpty) {
                                    final now = DateTime.now();
                                    final newOutfit = Outfit(
                                      id: now.millisecondsSinceEpoch.toString(),
                                      name: "${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.year}",
                                      items: items,
                                      savedDate: now,
                                    );
                                    dataService.addOutfit(newOutfit);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Outfit saved to closet!')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Could not find these items in your closet.')),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.checkroom),
                                label: const Text('Save Outfit'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                  foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                                onPressed: () async {
                                   final dataService = context.read<DataService>();
                                   for (var id in widget.itemIds) {
                                     await dataService.markItemDirty(id);
                                   }
                                   if (context.mounted) {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Sent to Hamper!')),
                                     );
                                     // Optionally reset state or hide
                                     setState(() {
                                       _isSelected = false;
                                     });
                                   }
                                },
                                icon: const Icon(Icons.local_laundry_service),
                                label: const Text('To Hamper'),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                           onPressed: () {
                             setState(() {
                               _isSelected = false;
                             });
                           },
                           child: const Text("Cancel Selection"),
                        )
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isSelected = true;
                        });
                      },
                      child: const Text('Select Outfit'),
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
