import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/pending_friend_request.dart';
import '../services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/glass_container.dart';
import '../theme/app_design.dart';

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
            SnackBar(content: Text('Friend request from ${request.senderUsername} $status.')),
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
    return GlassScaffold(
      appBar: AppBar(
        title: Text('Friend Requests', style: AppText.header),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<DataService>(
        builder: (context, dataService, child) {
          if (dataService.pendingFriendRequests.isEmpty) {
            return Center(
              child: Text(
                'No pending friend requests.',
                style: AppText.body.copyWith(color: Colors.white70),
              ),
            );
          }
          return ListView.builder(
            itemCount: dataService.pendingFriendRequests.length,
            itemBuilder: (context, index) {
              final request = dataService.pendingFriendRequests[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.all(12),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.white10,
                      backgroundImage: request.profilePicUrl != null
                          ? CachedNetworkImageProvider(request.profilePicUrl!)
                          : null,
                      child: request.profilePicUrl == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(request.senderUsername, style: AppText.bodyBold.copyWith(color: Colors.white)),
                    subtitle: Text(
                      'Sent you a friend request (${request.senderEmail})',
                      style: AppText.label.copyWith(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _respondToRequest(request, 'accepted'),
                          child: GlassContainer(
                            width: 36,
                            height: 36,
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.green.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                            child: const Icon(Icons.check, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _respondToRequest(request, 'rejected'),
                          child: GlassContainer(
                            width: 36,
                            height: 36,
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.red.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
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
