import 'package:flutter/material.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../../../core/theme/app_spacing.dart';

/// Animated page-position indicator for the onboarding carousel.
///
/// The active dot widens rather than only changing colour, so position stays
/// readable for users who cannot distinguish the two tints.
class OnboardingDotIndicator extends StatelessWidget {
  const OnboardingDotIndicator({
    required this.count,
    required this.activeIndex,
    super.key,
  });

  /// Dot geometry is component-specific: the active pill is three times the
  /// width of an inactive dot, so these stay local rather than using spacing
  /// tokens. The gap between dots is real spacing, so it uses [AppSpacing].
  static const double _dotSize = 8.0;
  static const double _activeDotWidth = 24.0;
  static const double _dotSpacing = AppSpacing.xs;
  static const double _inactiveOpacity = 0.3;

  /// Total number of pages.
  final int count;

  /// Zero-based index of the page currently in view.
  final int activeIndex;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Page ${activeIndex + 1} of $count',
        child: ExcludeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              count,
              (index) => _buildDot(context, index),
            ),
          ),
        ),
      );

  Widget _buildDot(BuildContext context, int index) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isActive = index == activeIndex;

    return AnimatedContainer(
      duration: UiConstants.animFast,
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: _dotSpacing),
      height: _dotSize,
      width: isActive ? _activeDotWidth : _dotSize,
      decoration: BoxDecoration(
        color: isActive
            ? colors.primary
            : colors.onSurfaceVariant.withValues(alpha: _inactiveOpacity),
        borderRadius: BorderRadius.circular(UiConstants.radiusRound),
      ),
    );
  }
}
