import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/glass_container.dart';
import '../theme/app_design.dart';

class FindFriendsScreen extends StatefulWidget {
  const FindFriendsScreen({super.key});

  @override
  State<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends State<FindFriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  final Set<String> _sentRequests = {}; // Track locally sent requests

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

  Future<void> _sendFriendRequest(String recipientId, String recipientName) async {
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

    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final success = await dataService.sendFriendRequest(senderUserEmail, recipientId);

      if (mounted) {
        if (success) {
          setState(() {
            _sentRequests.add(recipientId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Friend request sent to $recipientName.')),
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
    return GlassScaffold(
      appBar: AppBar(
        title: Text('Find Friends', style: AppText.header),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GlassContainer(
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white.withValues(alpha: 0.05),
              child: TextField(
                controller: _searchController,
                style: AppText.body.copyWith(color: Colors.white),
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  labelText: 'Search by Username',
                  labelStyle: AppText.label.copyWith(color: Colors.white70),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search, color: Colors.white70),
                          onPressed: _searchUsers,
                        ),
                ),
                onSubmitted: (_) => _searchUsers(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<DataService>(
                builder: (context, dataService, child) {
                  return ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      final userId = user['id'].toString();
                      final isFriend = dataService.friends.any((f) => f.id == userId);
                      final isPending = _sentRequests.contains(userId);

                      Widget trailingWidget;
                      if (isFriend) {
                        trailingWidget = Text('Your Friend', style: AppText.bodyBold.copyWith(color: AppColors.accent));
                      } else if (isPending) {
                        trailingWidget = Text('Request Pending', style: AppText.body.copyWith(color: Colors.white70));
                      } else {
                        trailingWidget = GestureDetector(
                          onTap: () => _sendFriendRequest(userId, user['username']),
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.accent.withValues(alpha: 0.2),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                            child: Text(
                              'Add Friend',
                              style: AppText.bodyBold.copyWith(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: GlassContainer(
                          borderRadius: BorderRadius.circular(16),
                          padding: const EdgeInsets.all(12),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Colors.white10,
                              backgroundImage: user['profile_pic_url'] != null
                                  ? CachedNetworkImageProvider(user['profile_pic_url'])
                                  : null,
                              child: user['profile_pic_url'] == null
                                  ? const Icon(Icons.person, color: Colors.white)
                                  : null,
                            ),
                            title: Text(user['username'], style: AppText.bodyBold.copyWith(color: Colors.white)),
                            subtitle: Text(user['favorite_style'] ?? 'N/A', style: AppText.label.copyWith(color: Colors.white70)),
                            trailing: trailingWidget,
                          ),
                        ),
                      );
                    },
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
