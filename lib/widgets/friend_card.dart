import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/friend.dart';
import 'glass_container.dart';
import '../theme/app_design.dart';

class FriendCard extends StatefulWidget {
  final Friend friend;
  final VoidCallback? onTap;

  const FriendCard({
    super.key, 
    required this.friend,
    this.onTap,
  });

  @override
  State<FriendCard> createState() => _FriendCardState();
}

class _FriendCardState extends State<FriendCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: GlassContainer(
            borderRadius: BorderRadius.circular(15),
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background items preview (faded)
                      Opacity(
                        opacity: 0.3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: widget.friend.previewItems.isEmpty 
                            ? Container(color: Colors.white10)
                            : GridView.count(
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                children: widget.friend.previewItems.take(4).map((item) {
                                  final isNetwork = item.imagePath.startsWith('http');
                                  if (isNetwork) {
                                    return CachedNetworkImage(
                                      imageUrl: item.imagePath,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(color: Colors.white10),
                                      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white24),
                                    );
                                  } else {
                                    return Image.asset(
                                      item.imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.white10),
                                    );
                                  }
                                }).toList(),
                              ),
                        ),
                      ),
                      // Profile Picture
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accent, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.black26,
                            backgroundImage: widget.friend.profilePicUrl != null
                                ? CachedNetworkImageProvider(widget.friend.profilePicUrl!)
                                : null,
                            child: widget.friend.profilePicUrl == null
                                ? const Icon(Icons.person, size: 40, color: Colors.white)
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    alignment: Alignment.center,
                    color: Colors.black.withValues(alpha: 0.2),
                    child: Text(
                      widget.friend.name,
                      style: AppText.bodyBold.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}