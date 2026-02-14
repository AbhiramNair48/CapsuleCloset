import 'package:flutter/material.dart';
import 'glass_scaffold.dart';
import 'glass_container.dart';
import '../theme/app_design.dart';

class GenericDeleteScreen<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) getId;
  final Widget Function(BuildContext context, T item, bool isSelected, VoidCallback onTap) itemBuilder;
  final void Function(Set<String> ids) onDelete;
  final String emptyMessage;
  final String deleteLabel;
  final String snackBarMessage;
  final SliverGridDelegate gridDelegate;

  const GenericDeleteScreen({
    super.key,
    required this.title,
    required this.items,
    required this.getId,
    required this.itemBuilder,
    required this.onDelete,
    required this.emptyMessage,
    this.deleteLabel = 'Delete',
    required this.snackBarMessage,
    required this.gridDelegate,
  });

  @override
  State<GenericDeleteScreen<T>> createState() => _GenericDeleteScreenState<T>();
}

class _GenericDeleteScreenState<T> extends State<GenericDeleteScreen<T>> {
  final Set<String> _selectedIds = {};

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _deleteSelected() {
    if (_selectedIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(widget.title, style: AppText.header),
        content: Text(
          'Are you sure you want to ${widget.deleteLabel.toLowerCase()} ${_selectedIds.length} item(s)?',
          style: AppText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              widget.onDelete(_selectedIds);
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Close screen
              messenger.showSnackBar(
                SnackBar(content: Text(widget.snackBarMessage)),
              );
            },
            child: Text(
              widget.deleteLabel,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        title: Text(widget.title, style: AppText.header),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: widget.items.isEmpty
          ? Center(
              child: Text(
                widget.emptyMessage,
                style: AppText.body.copyWith(fontSize: 18),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: widget.gridDelegate,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final id = widget.getId(item);
                final isSelected = _selectedIds.contains(id);

                return Stack(
                  children: [
                    widget.itemBuilder(
                      context,
                      item,
                      isSelected,
                      () => _toggleSelection(id),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
      floatingActionButton: _selectedIds.isNotEmpty
          ? GestureDetector(
              onTap: _deleteSelected,
              child: GlassContainer(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.delete, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.deleteLabel} (${_selectedIds.length})',
                      style: AppText.bodyBold.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
