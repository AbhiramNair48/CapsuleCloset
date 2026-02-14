import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/data_service.dart';
import '../models/clothing_item.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/glass_container.dart';
import '../theme/app_design.dart';

class HamperScreen extends StatelessWidget {
  const HamperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        title: Text('Hamper', style: AppText.header),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<DataService>(
            builder: (context, dataService, child) {
              if (dataService.hamperItems.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () async {
                    await dataService.markAllClean();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All clothes marked as clean!')),
                      );
                    }
                  },
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.accent.withValues(alpha: 0.2),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text('Clean All', style: AppText.bodyBold.copyWith(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<DataService>(
        builder: (context, dataService, child) {
          final hamperItems = dataService.hamperItems;

          if (hamperItems.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.local_laundry_service_outlined,
              message: 'Your hamper is empty!',
              buttonText: 'Back to Closet',
              onPressed: () => Navigator.pop(context),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
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

    return GlassContainer(
      borderRadius: BorderRadius.circular(12),
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: isNetworkImage
                      ? CachedNetworkImage(
                          imageUrl: item.imagePath,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.white10),
                          errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white54),
                        )
                      : Image.asset(
                          item.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white54),
                        ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12.0),
                color: Colors.black.withValues(alpha: 0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.type,
                      style: AppText.bodyBold.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.color,
                      style: AppText.label.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 8,
            top: 8,
            child: GestureDetector(
              onTap: () {
                context.read<DataService>().markItemClean(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.type} marked as clean')),
                );
              },
              child: GlassContainer(
                width: 36,
                height: 36,
                borderRadius: BorderRadius.circular(18),
                color: Colors.green.withValues(alpha: 0.3),
                border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                child: const Icon(Icons.restore_from_trash, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
