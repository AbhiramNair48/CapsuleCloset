import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../widgets/closet_content.dart';
import '../widgets/apparel_info_overlay.dart';
import '../widgets/glass_scaffold.dart';
import '../theme/app_design.dart';

class FriendClosetPage extends StatelessWidget {
  final List<ClothingItem> closetItems;
  final String friendName;

  const FriendClosetPage({
    super.key,
    required this.closetItems,
    required this.friendName,
  });

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        title: Text(friendName, style: AppText.header),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ClosetContent(
        items: closetItems,
        onItemTap: (item) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => ApparelInfoOverlay(
              item: item,
              onClose: () => Navigator.of(context).pop(),
              isReadOnly: true,
            ),
          );
        },
      ),
    );
  }
}

  