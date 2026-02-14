import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../widgets/generic_delete_screen.dart';
import '../models/friend.dart';
import '../widgets/friend_card.dart';
import '../theme/app_design.dart';

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
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppColors.accent : Colors.transparent,
                  width: 3.0,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: FriendCard(
                key: ValueKey(item.id),
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
