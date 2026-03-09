import 'package:flutter/material.dart';
import '../theme/app_design.dart';
import 'glass_container.dart';

class GlassTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const GlassTextField({
    super.key,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppText.label.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
        ],
        GlassContainer(
          borderRadius: BorderRadius.circular(borderRadius),
          padding: padding,
          color: Colors.white.withValues(alpha: 0.05),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, color: Colors.white70, size: 20),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  style: AppText.body.copyWith(color: Colors.white),
                  cursorColor: AppColors.accent,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: AppText.body.copyWith(color: Colors.white38),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: validator,
                ),
              ),
              if (suffixIcon != null) ...[
                const SizedBox(width: 8),
                suffixIcon!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
