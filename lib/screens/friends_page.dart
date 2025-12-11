import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import 'friend_closet_page.dart';
import 'delete_friends_screen.dart';
import '../widgets/friend_card.dart';
import 'find_friends_screen.dart';
import 'friend_requests_screen.dart';

// Search bar widget for the friends page
class _FriendSearchBar extends StatelessWidget {
  const _FriendSearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SearchBar(
        hintText: 'Search Friends',
        leading: const Icon(Icons.search),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        elevation: WidgetStateProperty.all(2.0),
        backgroundColor: WidgetStateProperty.all(Colors.white),
      ),
    );
  }
}

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FindFriendsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FriendRequestsScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DeleteFriendsScreen(),
            ),
          );
        },
        child: const Icon(Icons.person_remove_outlined),
      ),
      body: Column(
        children: [
          const _FriendSearchBar(),
          Expanded(
            child: Consumer<DataService>(
              builder: (context, dataService, child) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: dataService.friends.length,
                  itemBuilder: (context, index) {
                    final friend = dataService.friends[index];
                    return FriendCard(
                      friend: friend,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FriendClosetPage(
                              closetItems: friend.closetItems,
                              friendName: friend.name,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}