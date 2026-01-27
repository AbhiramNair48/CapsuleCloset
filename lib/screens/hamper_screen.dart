import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/data_service.dart';
import '../models/clothing_item.dart';
import '../widgets/empty_state_widget.dart';

class HamperScreen extends StatelessWidget {
  const HamperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hamper'),
        actions: [
          Consumer<DataService>(
            builder: (context, dataService, child) {
              if (dataService.hamperItems.isEmpty) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () async {
                  await dataService.markAllClean();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All clothes marked as clean!')),
                    );
                  }
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Clean All'),
              );
            },
          ),
        ],
      ),
      body: Consumer<DataService>(
        builder: (context, dataService, child) {
          final hamperItems = dataService.hamperItems;

          if (hamperItems.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.local_laundry_service_outlined,
              message: 'Your hamper is empty!',
              buttonText: 'Back to Closet',
              // onPressed handled by popping navigation usually, or could go back
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: hamperItems.length,
            itemBuilder: (context, index) {
              final item = hamperItems[index];
              return _HamperItemCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _HamperItemCard extends StatelessWidget {
  final ClothingItem item;

  const _HamperItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = item.imagePath.startsWith('http');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: isNetworkImage
                    ? CachedNetworkImage(
                        imageUrl: item.imagePath,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      )
                    : Image.asset(
                        item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.type,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.color,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 4,
            top: 4,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: IconButton(
                iconSize: 20,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.restore_from_trash, color: Colors.green),
                tooltip: 'Mark Clean',
                onPressed: () {
                  context.read<DataService>().markItemClean(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.type} marked as clean')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
