import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';
import '../design_system/design_tokens.dart';
import '../extensions/context_extensions.dart';

/// A generic custom card widget for lists and grids.
///
/// Design System: cards are border-first (`elevation.card` = a 1px hairline
/// border, no shadow) on the raised surface.
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

  /// LEGACY: ignored. AURA cards are border-first; see the constructor note.
  @Deprecated(
    'AuraCard is border-first under the Design System (a 1px border, no '
    'shadow). This value is ignored. Kept for source compatibility; scheduled '
    'for removal in a future cleanup step.',
  )
  final double elevation;

  @override
  Widget build(BuildContext context) {
    // Development-only signal: `elevation` is ignored under the Design System
    // (border-first). This assert is stripped from release builds, so there is
    // zero release overhead and no production logging, and it never throws.
    assert(() {
      if (elevation != UiConstants.elevationLow) {
        debugPrint(
          'AuraCard.elevation is ignored under the Design System (border-first). '
          'It is deprecated and scheduled for removal; remove the argument.',
        );
      }
      return true;
    }());
    return Card(
      // Border-first: no shadow. The `elevation` param above is intentionally
      // not consulted (documented, deprecated).
      elevation: 0,
      color: color ?? context.tokens.colors.surfaceRaised,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: context.tokens.colors.borderDefault,
          width: AuraBorders.hairline,
        ),
        borderRadius: BorderRadius.circular(AuraRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AuraRadius.md),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AuraSpacing.componentPadding),
          child: child,
        ),
      ),
    );
  }
}
