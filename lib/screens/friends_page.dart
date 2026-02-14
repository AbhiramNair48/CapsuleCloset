import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import 'friend_closet_page.dart';
import 'delete_friends_screen.dart';
import '../widgets/friend_card.dart';
import 'find_friends_screen.dart';
import 'friend_requests_screen.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/glass_container.dart';
import '../theme/app_design.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0), // Lift above custom nav bar
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const DeleteFriendsScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(position: animation.drive(tween), child: FadeTransition(opacity: animation, child: child));
                },
              ),
            );
          },
          child: GlassContainer(
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(28),
            blur: 20,
            color: AppColors.glassFill.withValues(alpha: 0.2),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            child: const Icon(Icons.person_remove_outlined, color: Colors.white),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                         // Optional: Handle tap if search functionality is added here directly or just visual
                      },
                      child: GlassContainer(
                        height: 50,
                        borderRadius: BorderRadius.circular(25),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        color: AppColors.glassFill.withValues(alpha: 0.1),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(
                              'Search Friends',
                              style: AppText.body.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const FindFriendsScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            return SlideTransition(position: animation.drive(tween), child: FadeTransition(opacity: animation, child: child));
                          },
                        ),
                      );
                    },
                    child: GlassContainer(
                      width: 50,
                      height: 50,
                      borderRadius: BorderRadius.circular(25),
                      color: AppColors.glassFill.withValues(alpha: 0.1),
                      child: const Icon(Icons.person_add, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const FriendRequestsScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            return SlideTransition(position: animation.drive(tween), child: FadeTransition(opacity: animation, child: child));
                          },
                        ),
                      );
                    },
                    child: GlassContainer(
                      width: 50,
                      height: 50,
                      borderRadius: BorderRadius.circular(25),
                      color: AppColors.glassFill.withValues(alpha: 0.1),
                      child: Consumer<DataService>(
                        builder: (context, dataService, child) {
                          final count = dataService.pendingFriendRequests.length;
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.group, color: Colors.white),
                              if (count > 0)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<DataService>(
                builder: (context, dataService, child) {
                  if (dataService.friends.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 125.0),
                      child: EmptyStateWidget(
                        icon: Icons.group_outlined,
                        message: '', // Hide message as per style
                                              buttonText: 'Find Friends',
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context, animation, secondaryAnimation) => const FindFriendsScreen(),
                                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                      const begin = Offset(0.0, 1.0);
                                                      const end = Offset.zero;
                                                      const curve = Curves.ease;
                                                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                      return SlideTransition(position: animation.drive(tween), child: FadeTransition(opacity: animation, child: child));
                                                    },
                                                  ),
                                                );
                                              },                      ),
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
      ),
    );
  }
}