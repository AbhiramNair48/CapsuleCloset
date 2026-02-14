import 'package:flutter/material.dart';
import '../theme/app_design.dart';

class GlassScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;
  final bool extendBodyBehindAppBar;
  final Widget? floatingActionButton;

  const GlassScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.appBar,
    this.extendBodyBehindAppBar = true,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Crucial for floating nav bar
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: Colors.transparent, // Defer to gradient
      appBar: appBar,
      body: Stack(
        children: [
          // Global Background Gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: SafeArea(
              bottom: false, // Allow content to flow behind nav bar area
              child: body,
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
