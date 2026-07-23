import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';
import '../extensions/context_extensions.dart';

/// A generic custom card widget for lists and grids.
class AuraCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double elevation;

  const AuraCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.elevation = UiConstants.elevationLow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: color ?? context.theme.cardTheme.color,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
