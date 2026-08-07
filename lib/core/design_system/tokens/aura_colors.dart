import 'package:flutter/painting.dart';

import 'aura_palette.dart';

/// Semantic color roles for the AURA Design System.
///
/// LAYER 2 (semantics). Every value is a *role* ("what is this for?"), resolved
/// per theme by mapping to a primitive in [AuraPalette]. This is the ONLY color
/// layer widgets may consume, and it is delivered through the `AuraTokens` theme
/// extension so a widget never has to know which theme is active.
///
/// Immutable. Two canonical instances: [AuraColors.light] and [AuraColors.dark].
class AuraColors {
  const AuraColors({
    required this.surfaceBackground,
    required this.surfaceReading,
    required this.surfaceRaised,
    required this.surfaceOverlay,
    required this.contentPrimary,
    required this.contentSecondary,
    required this.contentTertiary,
    required this.contentDisabled,
    required this.contentOnAction,
    required this.actionPrimary,
    required this.actionPressed,
    required this.actionSubtle,
    required this.actionDisabled,
    required this.borderDefault,
    required this.borderStrong,
    required this.divider,
    required this.focusRing,
    required this.selectionBackground,
    required this.statusSuccess,
    required this.statusWarning,
    required this.statusError,
    required this.statusInfo,
    required this.courseSlate,
    required this.courseSage,
    required this.courseClay,
    required this.coursePlum,
    required this.courseOchre,
    required this.courseTeal,
    required this.courseRose,
    required this.courseMoss,
  });

  /// Light theme mapping.
  static const AuraColors light = AuraColors(
    surfaceBackground: AuraPalette.n100,
    surfaceReading: AuraPalette.n50,
    surfaceRaised: AuraPalette.n0,
    surfaceOverlay: AuraPalette.n0,
    contentPrimary: AuraPalette.n900,
    contentSecondary: AuraPalette.n600,
    contentTertiary: AuraPalette.n500,
    contentDisabled: AuraPalette.n400,
    contentOnAction: AuraPalette.n0,
    actionPrimary: AuraPalette.blue60,
    actionPressed: AuraPalette.blue70,
    actionSubtle: AuraPalette.blue50,
    actionDisabled: AuraPalette.n400,
    borderDefault: AuraPalette.n300,
    borderStrong: AuraPalette.n400,
    divider: AuraPalette.n200,
    focusRing: AuraPalette.blue60,
    selectionBackground: AuraPalette.blue50,
    statusSuccess: AuraPalette.green60,
    statusWarning: AuraPalette.amber60,
    statusError: AuraPalette.red60,
    statusInfo: AuraPalette.blue60,
    courseSlate: AuraPalette.slateLight,
    courseSage: AuraPalette.sageLight,
    courseClay: AuraPalette.clayLight,
    coursePlum: AuraPalette.plumLight,
    courseOchre: AuraPalette.ochreLight,
    courseTeal: AuraPalette.tealLight,
    courseRose: AuraPalette.roseLight,
    courseMoss: AuraPalette.mossLight,
  );

  /// Dark theme mapping. Not an inversion: contrast is deliberately reduced,
  /// surfaces lift toward light, no pure black or pure white.
  static const AuraColors dark = AuraColors(
    surfaceBackground: AuraPalette.d100,
    surfaceReading: AuraPalette.d50,
    surfaceRaised: AuraPalette.d200,
    surfaceOverlay: AuraPalette.d250,
    contentPrimary: AuraPalette.d900,
    contentSecondary: AuraPalette.d600,
    contentTertiary: AuraPalette.d500,
    contentDisabled: AuraPalette.d400,
    contentOnAction: AuraPalette.onActionDark,
    actionPrimary: AuraPalette.blue30OnDark,
    actionPressed: AuraPalette.bluePressedDark,
    actionSubtle: AuraPalette.blueSubtleDark,
    actionDisabled: AuraPalette.d400,
    borderDefault: AuraPalette.d300,
    borderStrong: AuraPalette.d400,
    divider: AuraPalette.d200,
    focusRing: AuraPalette.blue30OnDark,
    selectionBackground: AuraPalette.blueSubtleDark,
    statusSuccess: AuraPalette.green40,
    statusWarning: AuraPalette.amber40,
    statusError: AuraPalette.red40,
    statusInfo: AuraPalette.blue30OnDark,
    courseSlate: AuraPalette.slateDark,
    courseSage: AuraPalette.sageDark,
    courseClay: AuraPalette.clayDark,
    coursePlum: AuraPalette.plumDark,
    courseOchre: AuraPalette.ochreDark,
    courseTeal: AuraPalette.tealDark,
    courseRose: AuraPalette.roseDark,
    courseMoss: AuraPalette.mossDark,
  );

  // Surfaces.
  final Color surfaceBackground;
  final Color surfaceReading;
  final Color surfaceRaised;
  final Color surfaceOverlay;

  // Content (text and icons).
  final Color contentPrimary;
  final Color contentSecondary;
  final Color contentTertiary;
  final Color contentDisabled;
  final Color contentOnAction;

  // Action / interactive.
  final Color actionPrimary;
  final Color actionPressed;
  final Color actionSubtle;
  final Color actionDisabled;

  // Structure.
  final Color borderDefault;
  final Color borderStrong;
  final Color divider;
  final Color focusRing;
  final Color selectionBackground;

  // Status.
  final Color statusSuccess;
  final Color statusWarning;
  final Color statusError;
  final Color statusInfo;

  // Course identity (color is never the sole identifier; always paired with a
  // monogram or name at the component layer).
  final Color courseSlate;
  final Color courseSage;
  final Color courseClay;
  final Color coursePlum;
  final Color courseOchre;
  final Color courseTeal;
  final Color courseRose;
  final Color courseMoss;

  static Color _l(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  /// Field-by-field interpolation, used by [AuraTokens.lerp] during theme
  /// transitions so tokens animate with the rest of the theme.
  static AuraColors lerp(AuraColors a, AuraColors b, double t) => AuraColors(
        surfaceBackground: _l(a.surfaceBackground, b.surfaceBackground, t),
        surfaceReading: _l(a.surfaceReading, b.surfaceReading, t),
        surfaceRaised: _l(a.surfaceRaised, b.surfaceRaised, t),
        surfaceOverlay: _l(a.surfaceOverlay, b.surfaceOverlay, t),
        contentPrimary: _l(a.contentPrimary, b.contentPrimary, t),
        contentSecondary: _l(a.contentSecondary, b.contentSecondary, t),
        contentTertiary: _l(a.contentTertiary, b.contentTertiary, t),
        contentDisabled: _l(a.contentDisabled, b.contentDisabled, t),
        contentOnAction: _l(a.contentOnAction, b.contentOnAction, t),
        actionPrimary: _l(a.actionPrimary, b.actionPrimary, t),
        actionPressed: _l(a.actionPressed, b.actionPressed, t),
        actionSubtle: _l(a.actionSubtle, b.actionSubtle, t),
        actionDisabled: _l(a.actionDisabled, b.actionDisabled, t),
        borderDefault: _l(a.borderDefault, b.borderDefault, t),
        borderStrong: _l(a.borderStrong, b.borderStrong, t),
        divider: _l(a.divider, b.divider, t),
        focusRing: _l(a.focusRing, b.focusRing, t),
        selectionBackground: _l(a.selectionBackground, b.selectionBackground, t),
        statusSuccess: _l(a.statusSuccess, b.statusSuccess, t),
        statusWarning: _l(a.statusWarning, b.statusWarning, t),
        statusError: _l(a.statusError, b.statusError, t),
        statusInfo: _l(a.statusInfo, b.statusInfo, t),
        courseSlate: _l(a.courseSlate, b.courseSlate, t),
        courseSage: _l(a.courseSage, b.courseSage, t),
        courseClay: _l(a.courseClay, b.courseClay, t),
        coursePlum: _l(a.coursePlum, b.coursePlum, t),
        courseOchre: _l(a.courseOchre, b.courseOchre, t),
        courseTeal: _l(a.courseTeal, b.courseTeal, t),
        courseRose: _l(a.courseRose, b.courseRose, t),
        courseMoss: _l(a.courseMoss, b.courseMoss, t),
      );
}
