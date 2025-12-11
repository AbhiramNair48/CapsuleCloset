import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/pending_friend_request.dart';
import '../services/auth_service.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?['id']?.toString();
    if (userId != null) {
      await Provider.of<DataService>(context, listen: false).fetchPendingFriendRequests(userId);
    }
  }

  Future<void> _respondToRequest(PendingFriendRequest request, String status) async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final success = await dataService.respondToFriendRequest(request.friendshipId, status);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Friend request from ${request.senderUsername} ${status}.')),
          );
          // Refresh the list
          _fetchRequests();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update friend request.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error responding to request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: Consumer<DataService>(
        builder: (context, dataService, child) {
          if (dataService.pendingFriendRequests.isEmpty) {
            return const Center(
              child: Text('No pending friend requests.'),
            );
          }
          return ListView.builder(
            itemCount: dataService.pendingFriendRequests.length,
            itemBuilder: (context, index) {
              final request = dataService.pendingFriendRequests[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(request.senderUsername),
                  subtitle: Text('Sent you a friend request (${request.senderEmail})'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _respondToRequest(request, 'accepted'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _respondToRequest(request, 'rejected'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
