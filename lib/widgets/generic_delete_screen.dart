import 'package:flutter/material.dart';

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
        title: Text(widget.title),
        content: Text('Are you sure you want to ${widget.deleteLabel.toLowerCase()} ${_selectedIds.length} item(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete(_selectedIds);
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Close screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(widget.snackBarMessage)),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(widget.deleteLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: widget.items.isEmpty
          ? Center(child: Text(widget.emptyMessage))
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
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
      floatingActionButton: _selectedIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _deleteSelected,
              label: Text('${widget.deleteLabel} (${_selectedIds.length})'),
              icon: const Icon(Icons.delete),
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            )
          : null,
    );
  }
}
