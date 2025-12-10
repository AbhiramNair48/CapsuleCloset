import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../widgets/generic_delete_screen.dart';
import '../models/friend.dart';
import '../widgets/friend_card.dart';

class DeleteFriendsScreen extends StatelessWidget {
  const DeleteFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        return GenericDeleteScreen<Friend>(
          title: 'Remove Friends',
          items: dataService.friends,
          getId: (item) => item.id,
          emptyMessage: 'No friends to remove',
          deleteLabel: 'Remove',
          snackBarMessage: 'Friends removed',
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250,
            childAspectRatio: 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          onDelete: (ids) {
            for (final id in ids) {
              dataService.removeFriend(id);
            }
          },
          itemBuilder: (context, item, isSelected, onTap) {
            return Container(
              decoration: isSelected
                  ? BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3.0,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    )
                  : null,
              child: FriendCard(
                friend: item,
                onTap: onTap,
              ),
            );
          },
        );
      },
    );
  }
}
