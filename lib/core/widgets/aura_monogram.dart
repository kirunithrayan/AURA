import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';
import '../extensions/context_extensions.dart';

/// The eight Design System course-identity colors.
///
/// Course color is identity, never decoration, and is always paired with a
/// name or monogram at the component layer.
enum AuraCourseColor { slate, sage, clay, plum, ochre, teal, rose, moss }

/// Monogram sizes, mapped to the existing spacing scale.
enum AuraMonogramSize { sm, md, lg }

/// A rounded-square course monogram: initials on a tinted course-color field.
///
/// Provides the non-color half of course identity so meaning survives in
/// grayscale. Shape, size mapping, initials algorithm, and typography tier are
/// implementation proposals, not Blueprint-defined.
class AuraMonogram extends StatelessWidget {
  const AuraMonogram({
    super.key,
    required this.label,
    required this.color,
    this.size = AuraMonogramSize.md,
  });

  final String label;
  final AuraCourseColor color;
  final AuraMonogramSize size;

  double get _dimension => switch (size) {
        AuraMonogramSize.sm => AuraSpacing.s32,
        AuraMonogramSize.md => AuraSpacing.s40,
        AuraMonogramSize.lg => AuraSpacing.s48,
      };

  String get _initials {
    final String trimmed = label.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    final List<String> parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return trimmed.length >= 2
        ? trimmed.substring(0, 2).toUpperCase()
        : trimmed.toUpperCase();
  }

  Color _courseColor(AuraColors colors) => switch (color) {
        AuraCourseColor.slate => colors.courseSlate,
        AuraCourseColor.sage => colors.courseSage,
        AuraCourseColor.clay => colors.courseClay,
        AuraCourseColor.plum => colors.coursePlum,
        AuraCourseColor.ochre => colors.courseOchre,
        AuraCourseColor.teal => colors.courseTeal,
        AuraCourseColor.rose => colors.courseRose,
        AuraCourseColor.moss => colors.courseMoss,
      };

  @override
  Widget build(BuildContext context) {
    final Color courseColor = _courseColor(context.tokens.colors);
    return ExcludeSemantics(
      child: Container(
        width: _dimension,
        height: _dimension,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: courseColor.withValues(alpha: AuraOpacity.tint),
          borderRadius: BorderRadius.circular(AuraRadius.md),
        ),
        // The monogram is a fixed-size identity chip, so at large text scales
        // the initials are scaled down to fit rather than clipped (Design
        // System definition of done: 200% text scale without clipping). No
        // information is lost: the monogram is decorative here, and the course
        // name always accompanies it. A no-op at normal text scale.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _initials,
            style: AuraTypography.titleSm.copyWith(color: courseColor),
          ),
        ),
      ),
    );
  }
}
