import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../services/data_service.dart';
import '../theme/app_design.dart';
import 'glass_container.dart';

/// Widget for displaying apparel information in a bottom sheet overlay
class ApparelInfoOverlay extends StatefulWidget {
  final ClothingItem item;
  final VoidCallback onClose;
  final bool isReadOnly;

  const ApparelInfoOverlay({
    super.key,
    required this.item,
    required this.onClose,
    this.isReadOnly = false,
  });

  @override
  State<ApparelInfoOverlay> createState() => ApparelInfoOverlayState();
}

class ApparelInfoOverlayState extends State<ApparelInfoOverlay> {
  late TextEditingController _typeController;
  late TextEditingController _materialController;
  late TextEditingController _colorController;
  late TextEditingController _styleController;
  late TextEditingController _descriptionController;
  late bool _isPublic;

  static const double _initialChildSize = 0.8;
  static const double _minChildSize = 0.4;
  static const double _maxChildSize = 0.9;
  static const double _borderRadius = 30.0;
  static const double _padding = 24.0;
  static const double _spacing = 16.0;
  static const double _fieldSpacing = 8.0;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.item.type);
    _materialController = TextEditingController(text: widget.item.material);
    _colorController = TextEditingController(text: widget.item.color);
    _styleController = TextEditingController(text: widget.item.style);
    _descriptionController = TextEditingController(text: widget.item.description);
    _isPublic = widget.item.isPublic;
  }

  @override
  void dispose() {
    _typeController.dispose();
    _materialController.dispose();
    _colorController.dispose();
    _styleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedItem = widget.item.copyWith(
      type: _typeController.text,
      material: _materialController.text,
      color: _colorController.text,
      style: _styleController.text,
      description: _descriptionController.text,
    );

    context.read<DataService>().updateClothingItem(updatedItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark background for the sheet
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(_borderRadius),
          topRight: Radius.circular(_borderRadius),
        ),
        border: Border.all(color: Colors.white24, width: 1),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Apparel Information',
                      style: AppText.header,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
                const SizedBox(height: _spacing),
                _buildTextField('Clothing Type', _typeController),
                const SizedBox(height: _spacing),
                _buildTextField('Material', _materialController),
                const SizedBox(height: _spacing),
                _buildTextField('Color', _colorController),
                const SizedBox(height: _spacing),
                _buildTextField('Style', _styleController),
                const SizedBox(height: _spacing),
                _buildTextField('Description', _descriptionController, maxLines: 4),
                const SizedBox(height: _padding),
                if (!widget.isReadOnly)
                  GlassContainer(
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: SwitchListTile(
                      title: Text('Make Public', style: AppText.bodyBold),
                      subtitle: Text('Allow friends to see this item.', style: AppText.label),
                      value: _isPublic,
                      activeTrackColor: AppColors.accent,
                      trackColor: WidgetStateProperty.resolveWith((states) => 
                        states.contains(WidgetState.selected) ? AppColors.accent.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3)
                      ),
                      onChanged: (bool value) {
                        setState(() {
                          _isPublic = value;
                        });
                        context
                            .read<DataService>()
                            .updateClothingItemPublicStatus(widget.item.id, value);
                      },
                    ),
                  ),
                if (!widget.isReadOnly) ...[
                  const SizedBox(height: _padding),
                  GestureDetector(
                    onTap: _saveChanges,
                    child: GlassContainer(
                      height: 56,
                      borderRadius: BorderRadius.circular(28),
                      color: AppColors.accent.withValues(alpha: 0.2),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                      child: Center(
                        child: Text(
                          'Save Changes',
                          style: AppText.bodyBold.copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: _padding),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.label.copyWith(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: _fieldSpacing),
        GlassContainer(
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white.withValues(alpha: 0.05),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            readOnly: widget.isReadOnly,
            style: AppText.body.copyWith(color: Colors.white),
            cursorColor: AppColors.accent,
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

