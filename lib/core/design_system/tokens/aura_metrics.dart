/// Icon-metric tokens for the AURA Design System.
///
/// One family, one stroke weight, three sizes. Theme-independent.
class AuraIconTokens {
  const AuraIconTokens._();

  static const double sizeSm = 20;
  static const double sizeMd = 24;
  static const double sizeLg = 32;
  static const double stroke = 1.75;
}

/// Layout tokens for the AURA Design System.
///
/// Reading measure cap, touch-target minimums, breakpoints, and fixed chrome
/// heights. Theme-independent.
class AuraLayout {
  const AuraLayout._();

  /// Reading measure cap (~75 characters) at every breakpoint.
  static const double readingContainerMax = 680;

  static const double touchTargetMin = 48;
  static const double touchTargetGap = 8;

  static const double breakpointCompact = 600;
  static const double breakpointExpanded = 904;

  static const double appBarHeight = 56;
}

/// Opacity tokens for the AURA Design System.
///
/// Named so the values already used across the specs (monogram tint, scrim,
/// status fills) never appear as magic numbers.
class AuraOpacity {
  const AuraOpacity._();

  static const double subtle = 0.08;
  static const double tint = 0.16;
  static const double selection = 0.24;
  static const double selectionDark = 0.32;
  static const double scrim = 0.32;
  static const double disabled = 0.38;
}
