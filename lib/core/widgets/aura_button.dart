import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';
import '../extensions/context_extensions.dart';

/// Emphasis variants for [AuraButton].
///
/// `primary` is the single high-emphasis action; the Design System allows at
/// most one primary button per screen. That is a screen-level rule and is not
/// enforced by this widget.
enum AuraButtonVariant { primary, secondary, text }

/// The AURA button. Emphasis is chosen by [variant]; there are no
/// variant-specific subclasses.
///
/// A null [onPressed] renders the disabled state.
class AuraButton extends StatelessWidget {
  const AuraButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AuraButtonVariant.secondary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AuraButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final AuraColors colors = context.tokens.colors;
    final bool enabled = onPressed != null;
    final IconData? leadingIcon = icon;

    final Color? fill = switch (variant) {
      AuraButtonVariant.primary =>
        enabled ? colors.actionPrimary : colors.actionDisabled,
      AuraButtonVariant.secondary => null,
      AuraButtonVariant.text => null,
    };
    // A primary label always sits on a fill, so it keeps the on-action role in
    // both states (only the fill drops to actionDisabled). Secondary/text drop
    // to the disabled content color.
    final Color foreground = switch (variant) {
      AuraButtonVariant.primary => colors.contentOnAction,
      AuraButtonVariant.secondary =>
        enabled ? colors.contentPrimary : colors.contentDisabled,
      AuraButtonVariant.text =>
        enabled ? colors.actionPrimary : colors.contentDisabled,
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: fill ?? Colors.transparent,
        borderRadius: BorderRadius.circular(AuraRadius.sm),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AuraRadius.sm),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AuraLayout.touchTargetMin,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AuraSpacing.componentPadding,
            ),
            decoration: variant == AuraButtonVariant.secondary
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(AuraRadius.sm),
                    border: Border.all(
                      color: enabled ? colors.borderStrong : colors.actionDisabled,
                      width: AuraBorders.hairline,
                    ),
                  )
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (leadingIcon != null) ...<Widget>[
                  Icon(leadingIcon, size: AuraIconTokens.sizeSm, color: foreground),
                  const SizedBox(width: AuraSpacing.gapTight),
                ],
                Text(
                  label,
                  style: AuraTypography.label.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
