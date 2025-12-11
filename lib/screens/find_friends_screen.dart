import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';

class FindFriendsScreen extends StatefulWidget {
  const FindFriendsScreen({super.key});

  @override
  State<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends State<FindFriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchUsers() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final results = await dataService.searchUsers(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching users: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendFriendRequest(String recipientId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final senderUserEmail = authService.currentUser?['email']?.toString();

    if (senderUserEmail == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to send friend requests.')),
        );
      }
      return;
    }

    // You might still want to prevent sending a request to yourself
    // For this, you would need the recipient's email or compare IDs after fetching user details
    final senderId = authService.currentUser?['id']?.toString();
    if (senderId != null && senderId == recipientId) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot send friend request to yourself.')),
        );
      }
      return;
    }

    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final success = await dataService.sendFriendRequest(senderUserEmail, recipientId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Friend request sent to ${recipientId}.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send friend request.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending friend request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Friends'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Username',
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _searchUsers,
                      ),
              ),
              onSubmitted: (_) => _searchUsers(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(user['username']),
                      subtitle: Text(user['favorite_style'] ?? 'N/A'),
                      trailing: ElevatedButton(
                        onPressed: () => _sendFriendRequest(user['id'].toString()),
                        child: const Text('Add Friend'),
                      ),
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
