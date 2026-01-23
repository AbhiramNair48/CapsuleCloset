import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/outfit.dart';

/// OutfitPreview widget to display clothing images
/// Shows a list of outfit images in a vertical layout
class OutfitPreview extends StatelessWidget {
  final List<String> imagePaths;
  final List<String> itemIds;

  const OutfitPreview({
    super.key,
    required this.imagePaths,
    this.itemIds = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
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
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              final imagePath = imagePaths[index];
              final isNetworkImage = imagePath.startsWith('http');

              return Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 8.0),
                child: Container(
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
              );
            },
          ),
          if (itemIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final dataService = context.read<DataService>();
                    final items = dataService.clothingItems
                        .where((item) => itemIds.contains(item.id))
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
            ),
        ],
      ),
    );
  }
}
