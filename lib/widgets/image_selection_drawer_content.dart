import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'delete_icon_button.dart';

class ImageSelectionDrawerContent extends StatefulWidget {
  final List<XFile> images;
  final Function(int index) onRemove;
  final VoidCallback onDone;
  final ScrollController scrollController;

  const ImageSelectionDrawerContent({
    super.key,
    required this.images,
    required this.onRemove,
    required this.onDone,
    required this.scrollController,
  });

  @override
  State<ImageSelectionDrawerContent> createState() => _ImageSelectionDrawerContentState();
}

class _ImageSelectionDrawerContentState extends State<ImageSelectionDrawerContent> {
  // We keep a local reference to the list to animate/update UI immediately
  // but the source of truth is passed from parent. 
  // Actually, since parent updates the list and rebuilds this widget? 
  // No, showModalBottomSheet builder is not automatically rebuilt when parent setState is called 
  // UNLESS we use a StatefulBuilder inside the parent (which it did).
  // But here we are making THIS widget stateful, so we can manage the list view.
  
  late List<XFile> _drawerImages;

  @override
  void initState() {
    super.initState();
    _drawerImages = List.from(widget.images);
  }

  void _handleRemove(int index) {
    setState(() {
      _drawerImages.removeAt(index);
    });
    widget.onRemove(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected Items (${_drawerImages.length})',
                  style: theme.textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: widget.onDone,
                  child: const Text('Done'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                controller: widget.scrollController,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 120,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _drawerImages.length,
                itemBuilder: (context, index) {
                  if (index >= _drawerImages.length) {
                    return Container();
                  }
                  
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(_drawerImages[index].path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.broken_image,
                              size: 30,
                              color: Colors.grey,
                            );
                          },
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: DeleteIconButton(
                            onTap: () => _handleRemove(index),
                            iconSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
