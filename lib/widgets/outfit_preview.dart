import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:capsule_closet_app/services/data_service.dart';
import 'package:capsule_closet_app/models/outfit.dart';
import 'package:provider/provider.dart';
import '../theme/app_design.dart';
import 'glass_container.dart';

class OutfitPreview extends StatelessWidget {
  final List<String> imagePaths;
  final List<String> itemIds;
  final String? outfitName;

  const OutfitPreview({
    super.key,
    required this.imagePaths,
    this.itemIds = const [],
    this.outfitName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional Label
        // Padding(
        //   padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
        //   child: Text("Here's a look for you:", style: AppText.label),
        // ),
        GlassContainer(
          width: double.infinity,
          borderRadius: BorderRadius.circular(AppRadius.card),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
               // Image Grid/Stack
               // For now, simple list view inside
               _buildImages(context),
               
               const SizedBox(height: 16),
               
               // Actions
               Row(
                 children: [
                   Expanded(
                     child: _ActionButton(
                       label: "Save to Closet",
                       icon: Icons.checkroom,
                       onTap: () => _saveOutfit(context),
                     ),
                   ),
                   const SizedBox(width: 12),
                   Expanded( // Added Expanded for equal width buttons
                     child: _ActionButton(
                       label: "Hamper",
                       icon: Icons.local_laundry_service,
                       onTap: () => _sendToHamper(context),
                       isPrimary: false,
                     ),
                   ),
                 ],
               )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImages(BuildContext context) {
    if (imagePaths.isEmpty) return const SizedBox.shrink();
    
    // If only one image, show it full size
    if (imagePaths.length == 1) {
      return Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black12,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _buildImage(imagePaths.first),
        ),
      );
    }

    // Grid layout for multiple images
    return Container(
      // Constrain height based on row count (approx 150px per row) to avoid infinite height in Column
      height: (imagePaths.length / 2).ceil() * 160.0, 
      constraints: const BoxConstraints(maxHeight: 400), // Max height limit
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          physics: imagePaths.length <= 2 ? const NeverScrollableScrollPhysics() : null, // Disable scroll for few items
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8, // Taller items
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: imagePaths.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImage(imagePaths[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
      );
    }
    return Image.asset(path, fit: BoxFit.contain);
  }

  Future<void> _saveOutfit(BuildContext context) async {
    final dataService = context.read<DataService>();
    final items = dataService.clothingItems
        .where((item) => itemIds.contains(item.id))
        .toList();

    if (items.isNotEmpty) {
      final now = DateTime.now();
      final name = outfitName ?? "${now.month}-${now.day} Look";
      
      final newOutfit = Outfit(
        id: now.millisecondsSinceEpoch.toString(),
        name: name,
        items: items,
        savedDate: now,
      );
      dataService.addOutfit(newOutfit);
    }
  }

  Future<void> _sendToHamper(BuildContext context) async {
    final dataService = context.read<DataService>();
    for (var id in itemIds) {
      await dataService.markItemDirty(id);
    }
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Future<void> Function() onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = true,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isSuccess = false;

  void _handleTap() async {
    if (_isSuccess) return;

    await widget.onTap();

    if (mounted) {
      setState(() {
        _isSuccess = true;
      });

      // Revert back after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isSuccess = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: widget.isPrimary ? AppColors.glassFill : Colors.transparent,
          border: Border.all(color: _isSuccess ? AppColors.accent : AppColors.glassBorder),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _isSuccess
              ? Row(
                  key: const ValueKey("success"),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 18, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      "Done",
                      style: AppText.bodyBold.copyWith(fontSize: 12, color: AppColors.accent),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey("normal"),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, size: 18, color: widget.isPrimary ? Colors.white : AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: widget.isPrimary 
                          ? AppText.bodyBold.copyWith(fontSize: 12) 
                          : AppText.body.copyWith(fontSize: 12),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}