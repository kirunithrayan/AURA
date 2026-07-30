import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';
import '../extensions/context_extensions.dart';

/// A custom search bar styled for AURA.
class AuraSearchBar extends StatelessWidget {

  const AuraSearchBar({
    super.key,
    required this.hintText,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.readOnly = false,
    this.onTap,
  });
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final VoidCallback? onClear;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(UiConstants.radiusRound),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: (_) => onSubmitted?.call(),
        readOnly: readOnly,
        onTap: onTap,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search, color: context.theme.colorScheme.onSurfaceVariant),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
    );
}
