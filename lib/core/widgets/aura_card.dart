import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';
import '../extensions/context_extensions.dart';

/// A generic custom card widget for lists and grids.
class AuraCard extends StatelessWidget {

  const AuraCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.color,
    this.elevation = UiConstants.elevationLow,
  });
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double elevation;

  @override
  Widget build(BuildContext context) => Card(
      elevation: elevation,
      color: color ?? context.theme.cardTheme.color,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
}
