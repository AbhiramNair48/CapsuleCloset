import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../services/data_service.dart';

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
  static const double _borderRadius = 16.0;
  static const double _padding = 24.0;
  static const double _spacing = 16.0;
  static const double _fieldSpacing = 8.0;
  static const double _textFieldBorderRadius = 8.0;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Apparel Information',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
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
                  SwitchListTile(
                    title: const Text('Make Public'),
                    subtitle: const Text('Allow friends to see this item.'),
                    value: _isPublic,
                    onChanged: (bool value) {
                      setState(() {
                        _isPublic = value;
                      });
                      context
                          .read<DataService>()
                          .updateClothingItemPublicStatus(widget.item.id, value);
                    },
                  ),
                if (!widget.isReadOnly) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_textFieldBorderRadius),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: _fieldSpacing),
        TextField(
          controller: controller,
          maxLines: maxLines,
          readOnly: widget.isReadOnly,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_textFieldBorderRadius),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
      ],
    );
  }
}

