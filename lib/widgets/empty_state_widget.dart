import 'package:flutter/material.dart';
import '../theme/app_design.dart';
import 'glass_container.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80, // Slightly larger
              color: AppColors.accent,
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 32),
              GestureDetector(
                onTap: onPressed,
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(30),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  color: AppColors.glassFill.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                  child: Text(
                    buttonText!,
                    style: AppText.bodyBold.copyWith(
                      color: Colors.white,
                      fontSize: 13, // Reduced size
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
