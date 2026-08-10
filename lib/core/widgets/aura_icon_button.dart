import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';
import '../extensions/context_extensions.dart';

/// An icon-only button for AURA.
///
/// A [tooltip] is required by the Design System (§8): every icon button must
/// name its action. The icon renders at 24dp within a 48dp touch target.
///
/// Note: the Design System's 1.75px icon stroke is not yet expressible — no
/// variable icon font asset is bundled — so Material Icons are used and the
/// stroke requirement remains a documented gap, not a claimed feature.
class AuraIconButton extends StatelessWidget {
  const AuraIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = AuraIconTokens.sizeMd,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final AuraColors colors = context.tokens.colors;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      iconSize: size,
      color: colors.contentSecondary,
      disabledColor: colors.contentDisabled,
      constraints: const BoxConstraints(
        minWidth: AuraLayout.touchTargetMin,
        minHeight: AuraLayout.touchTargetMin,
      ),
      icon: Icon(icon),
    );
  }
}
