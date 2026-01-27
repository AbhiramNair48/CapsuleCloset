import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/friend.dart';

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
    final theme = Theme.of(context);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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
                      child: widget.friend.previewItems.isEmpty 
                        ? Container(color: theme.colorScheme.surfaceContainerHighest)
                        : GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            children: widget.friend.previewItems.take(4).map((item) {
                              final isNetwork = item.imagePath.startsWith('http');
                              if (isNetwork) {
                                return CachedNetworkImage(
                                  imageUrl: item.imagePath,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                );
                              } else {
                                return Image.asset(
                                  item.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
                                );
                              }
                            }).toList(),
                          ),
                    ),
                    // Profile Picture (Clickable)
                    Center(
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        elevation: 4,
                        child: InkWell(
                          onTap: widget.onTap,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: theme.colorScheme.surface,
                            backgroundImage: widget.friend.profilePicUrl != null
                                ? CachedNetworkImageProvider(widget.friend.profilePicUrl!)
                                : null,
                            child: widget.friend.profilePicUrl == null
                                ? Icon(Icons.person, size: 40, color: theme.colorScheme.onSurface)
                                : null,
                          ),
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
                  child: Text(
                    widget.friend.name,
                    style: theme.textTheme.titleSmall?.copyWith(
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
      ),
    );
  }
}