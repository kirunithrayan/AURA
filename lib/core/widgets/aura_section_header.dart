import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';
import '../extensions/context_extensions.dart';

/// A header row above a content section: a title with an optional trailing
/// action.
///
/// Design System: section headers never nest, and the surrounding vertical
/// rhythm belongs to the parent section, not this widget.
class AuraSectionHeader extends StatelessWidget {
  const AuraSectionHeader({
    super.key,
    required this.title,
    this.action,
  });

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final Widget? trailing = action;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: AuraTypography.titleMd.copyWith(
              color: context.tokens.colors.contentPrimary,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
