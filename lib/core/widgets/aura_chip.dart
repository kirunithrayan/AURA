import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

/// A custom chip widget used for tags and filters in AURA.
class AuraChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool isSelected;
  final IconData? icon;
  final Color? color;

  const AuraChip({
    super.key,
    required this.label,
    this.onTap,
    this.onDeleted,
    this.isSelected = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? context.theme.colorScheme.primary;

    return ActionChip(
      label: Text(label),
      avatar: icon != null ? Icon(icon, size: 16) : null,
      onPressed: onTap,
      backgroundColor: isSelected 
          ? chipColor 
          : chipColor.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected 
            ? context.theme.colorScheme.onPrimary 
            : chipColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
