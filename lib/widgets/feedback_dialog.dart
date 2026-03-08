import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:capsule_closet_app/config/app_constants.dart';
import '../theme/app_design.dart';
import 'glass_container.dart';

/// Shows the glass-styled feedback dialog. Use after 10 outfit creations or from profile.
void showFeedbackDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: Text("We'd love to hear from you!", style: AppText.header.copyWith(fontSize: 20)),
      content: GlassContainer(
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: AppColors.glassFill.withValues(alpha: 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your feedback helps us improve Capsule Closet.',
              style: AppText.body.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _openFeedbackLink(context),
              child: Text(
                'Give Feedback',
                style: AppText.bodyBold.copyWith(
                  fontSize: 16,
                  color: AppColors.accent,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Maybe later', style: TextStyle(color: Colors.white70)),
        ),
      ],
    ),
  );
}

Future<void> _openFeedbackLink(BuildContext context) async {
  final urlString = AppConstants.feedbackFormUrl;
  if (urlString.isEmpty) {
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback link is not configured yet.')),
      );
    }
    return;
  }
  final uri = Uri.parse(urlString);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  if (context.mounted) {
    Navigator.pop(context);
  }
}
