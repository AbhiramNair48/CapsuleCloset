import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/friend.dart';

class DeleteFriendsScreen extends StatefulWidget {
  const DeleteFriendsScreen({super.key});

  @override
  State<DeleteFriendsScreen> createState() => _DeleteFriendsScreenState();
}

class _DeleteFriendsScreenState extends State<DeleteFriendsScreen> {
  final Set<String> _selectedFriendIds = {};

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedFriendIds.contains(id)) {
        _selectedFriendIds.remove(id);
      } else {
        _selectedFriendIds.add(id);
      }
    });
  }

  void _deleteSelected() {
    if (_selectedFriendIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Friends'),
        content: Text('Are you sure you want to remove ${_selectedFriendIds.length} friend(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final dataService = context.read<DataService>();
              for (final id in _selectedFriendIds) {
                dataService.removeFriend(id);
              }
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Friends removed')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Friends'),
      ),
      body: Consumer<DataService>(
        builder: (context, dataService, child) {
          final friends = dataService.friends;

          if (friends.isEmpty) {
            return const Center(
              child: Text('No friends to remove'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              final isSelected = _selectedFriendIds.contains(friend.id);

              return Stack(
                children: [
                  Container(
                    decoration: isSelected
                        ? BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          )
                        : null,
                    child: _FriendCard(
                      friend: friend,
                      onTap: () => _toggleSelection(friend.id),
                    ),
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
          );
        },
      ),
      floatingActionButton: _selectedFriendIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _deleteSelected,
              label: Text('Remove (${_selectedFriendIds.length})'),
              icon: const Icon(Icons.person_remove),
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            )
          : null,
    );
  }
}

class _FriendCard extends StatelessWidget {
  final Friend friend;
  final VoidCallback onTap;

  const _FriendCard({required this.friend, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                children: friend.previewItems.take(4).map((item) {
                  return Image.asset(
                    item.imagePath,
                    fit: BoxFit.cover,
                  );
                }).toList(),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Text(
                  friend.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
