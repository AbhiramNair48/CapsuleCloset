import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_design.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final double opacity;
  final Border? border;
  final Color? color;
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.margin,
    this.blur = 15.0,
    this.opacity = 0.05,
    this.border,
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(AppRadius.card);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? AppColors.glassFill,
              borderRadius: effectiveBorderRadius,
              border: border ?? Border.all(color: AppColors.glassBorder, width: 1.0),
              gradient: gradient,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
