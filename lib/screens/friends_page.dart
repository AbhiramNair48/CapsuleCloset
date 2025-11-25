import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/friend.dart';
import '../services/data_service.dart';
import 'friend_closet_page.dart';

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
      // Background handled by theme
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
                    return _FriendCard(friend: friend);
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

class _FriendCard extends StatelessWidget {
  final Friend friend;

  const _FriendCard({required this.friend});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
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