import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';

/// A container that applies a glassmorphism effect (blur + translucency).
class GlassContainer extends StatelessWidget {

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = UiConstants.radiusMedium,
    this.padding,
  });
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final glassColor = isDark ? AppColors.glassDark : AppColors.glassLight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: UiConstants.glassBlur,
          sigmaY: UiConstants.glassBlur,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: context.theme.colorScheme.outline.withValues(alpha: UiConstants.glassBorderOpacity),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
