import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../widgets/closet_content.dart';
import '../widgets/apparel_info_overlay.dart';

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

      return Scaffold(

        // Background color handled by theme

        appBar: AppBar(

          title: Text(friendName), // Style handled by app_theme.dart

          backgroundColor: Colors.transparent,

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

              ),

            );

          },

        ),

      );

    }

  }

  