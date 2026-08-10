import 'package:flutter/material.dart';
import '../design_system/design_tokens.dart';
import '../extensions/context_extensions.dart';

/// A custom chip widget used for tags and filters in AURA.
///
/// Design System: chips are outlined at rest and take a subtle-action fill when
/// selected.
class AuraChip extends StatelessWidget {

  const AuraChip({
    super.key,
    required this.label,
    this.onTap,
    this.onDeleted,
    this.isSelected = false,
    this.icon,
    this.color,
  });
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool isSelected;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final AuraColors colors = context.tokens.colors;
    final Color accent = color ?? colors.actionPrimary;

    return ActionChip(
      label: Text(label),
      avatar: icon != null ? Icon(icon, size: AuraIconTokens.sizeSm) : null,
      onPressed: onTap,
      backgroundColor: isSelected ? colors.actionSubtle : Colors.transparent,
      labelStyle: AuraTypography.label.copyWith(
        color: isSelected ? accent : colors.contentPrimary,
      ),
      side: isSelected
          ? BorderSide.none
          : BorderSide(color: colors.borderDefault, width: AuraBorders.hairline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AuraRadius.sm),
      ),
    );
  }
}
