import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../models/onboarding_page_data.dart';

/// Renders one onboarding page.
///
/// The body scrolls when it cannot fit, so large system text scaling, short
/// landscape viewports and small devices degrade gracefully instead of
/// overflowing.
class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({required this.data, super.key});

  /// Below this viewport height the layout switches to its compact metrics
  /// (roughly: a phone held in landscape).
  static const double _compactHeightBreakpoint = 420.0;

  static const double _iconSize = 88.0;
  static const double _compactIconSize = 56.0;
  static const double _iconPadding = 28.0;
  static const double _compactIconPadding = 20.0;

  /// Caps line length so text stays readable on tablets and in landscape.
  static const double _maxContentWidth = 480.0;

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact =
              constraints.maxHeight < _compactHeightBreakpoint;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: isCompact ? AppSpacing.md : AppSpacing.lg,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _maxContentWidth,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildIcon(context, isCompact: isCompact),
                        SizedBox(
                          height: isCompact ? AppSpacing.lg : AppSpacing.xl,
                        ),
                        _buildTitle(context),
                        AppSpacing.v12,
                        _buildDescription(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

  Widget _buildIcon(BuildContext context, {required bool isCompact}) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ExcludeSemantics(
      child: Container(
        padding: EdgeInsets.all(
          isCompact ? _compactIconPadding : _iconPadding,
        ),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          data.icon,
          size: isCompact ? _compactIconSize : _iconSize,
          color: colors.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Text(
      data.title,
      textAlign: TextAlign.center,
      style: theme.textTheme.headlineSmall?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Text(
      data.description,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
    );
  }
}
