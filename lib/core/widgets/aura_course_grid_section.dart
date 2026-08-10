import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';
import 'aura_course_tile.dart';
import 'aura_monogram.dart';
import 'aura_section_header.dart';

/// Display data for one course in an [AuraCourseGridSection].
///
/// The section takes normalized display data rather than a repository entity,
/// so the widget layer holds no data-access concern.
@immutable
class AuraCourseData {
  const AuraCourseData({
    required this.name,
    required this.color,
    required this.onTap,
    this.onLongPress,
  });

  final String name;
  final AuraCourseColor color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
}

/// A section that lays out course tiles in a wrapping grid with a 16dp gutter.
///
/// The section owns the inter-tile spacing and its optional header; each tile
/// owns only its own padding.
class AuraCourseGridSection extends StatelessWidget {
  const AuraCourseGridSection({
    super.key,
    required this.courses,
    this.header,
  });

  final List<AuraCourseData> courses;
  final AuraSectionHeader? header;

  @override
  Widget build(BuildContext context) {
    final AuraSectionHeader? sectionHeader = header;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (sectionHeader != null) ...<Widget>[
          sectionHeader,
          const SizedBox(height: AuraSpacing.componentGap),
        ],
        Wrap(
          spacing: AuraSpacing.s16,
          runSpacing: AuraSpacing.s16,
          children: <Widget>[
            for (final AuraCourseData course in courses)
              AuraCourseTile(
                name: course.name,
                color: course.color,
                onTap: course.onTap,
                onLongPress: course.onLongPress,
              ),
          ],
        ),
      ],
    );
  }
}
