import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';
import '../extensions/context_extensions.dart';
import 'aura_monogram.dart';

/// Course-tile variants. The Blueprint establishes two variants; these names
/// map the existing `isListMode` distinction and are an implementation
/// proposal.
enum AuraCourseTileVariant { grid, list }

/// A course tile. Course color is identity, always paired with the course name
/// via an [AuraMonogram]. Flat (no shadow, no border) per the Design System.
class AuraCourseTile extends StatelessWidget {
  const AuraCourseTile({
    super.key,
    required this.name,
    required this.color,
    required this.onTap,
    this.variant = AuraCourseTileVariant.grid,
    this.onLongPress,
  });

  final String name;
  final AuraCourseColor color;
  final VoidCallback onTap;
  final AuraCourseTileVariant variant;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final AuraColors colors = context.tokens.colors;
    final bool isGrid = variant == AuraCourseTileVariant.grid;

    final Widget monogram = AuraMonogram(
      label: name,
      color: color,
      size: isGrid ? AuraMonogramSize.lg : AuraMonogramSize.md,
    );
    final Widget nameText = Text(
      name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AuraTypography.titleSm.copyWith(color: colors.contentPrimary),
    );

    final Widget content = isGrid
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              monogram,
              const SizedBox(height: AuraSpacing.componentGap),
              nameText,
            ],
          )
        : Row(
            children: <Widget>[
              monogram,
              const SizedBox(width: AuraSpacing.componentGap),
              Expanded(child: nameText),
            ],
          );

    return Semantics(
      button: true,
      label: name,
      child: Material(
        color: colors.surfaceBackground,
        borderRadius: BorderRadius.circular(AuraRadius.md),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AuraRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AuraSpacing.componentPadding),
            child: ExcludeSemantics(child: content),
          ),
        ),
      ),
    );
  }
}
