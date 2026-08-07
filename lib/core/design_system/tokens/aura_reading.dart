import 'package:flutter/painting.dart';

import 'aura_palette.dart';

/// A reading surface + ink pairing for one reading theme.
///
/// Reading themes (paper / sepia / night) are an axis INDEPENDENT of the app
/// light/dark theme: a student may read in night mode inside a light app. These
/// therefore live outside the [AuraTokens] extension.
class AuraReadingColors {
  const AuraReadingColors({
    required this.surface,
    required this.ink,
    required this.inkSecondary,
  });

  /// Default daytime reading surface.
  static const AuraReadingColors paper = AuraReadingColors(
    surface: AuraPalette.n50,
    ink: AuraPalette.n900,
    inkSecondary: AuraPalette.n600,
  );

  /// Warm, reduced-contrast surface for long sessions.
  static const AuraReadingColors sepia = AuraReadingColors(
    surface: AuraPalette.sepiaSurface,
    ink: AuraPalette.sepiaInk,
    inkSecondary: AuraPalette.sepiaInkSecondary,
  );

  /// Low-light surface. Deliberately reduced contrast (no pure black/white).
  static const AuraReadingColors night = AuraReadingColors(
    surface: AuraPalette.d50,
    ink: AuraPalette.d900,
    inkSecondary: AuraPalette.d600,
  );

  final Color surface;
  final Color ink;
  final Color inkSecondary;
}

/// Reading typography tokens for the AURA Design System.
///
/// Source Serif 4 for content, because reading is the primary activity and the
/// serif signals "text to be read." Body leading is 1.65 — the single most
/// important metric in the system for sustained sessions. Colors come from
/// [AuraReadingColors]; these styles carry metrics only.
class AuraReading {
  const AuraReading._();

  /// Reading family. Bundled in Step 0; matches the `pubspec` declaration.
  static const String fontFamily = 'Source Serif 4';

  /// User-selectable body sizes; [defaultSize] is the initial value.
  static const List<double> sizeSteps = <double>[15, 16, 17, 19, 21];
  static const double defaultSize = 17;

  /// Body leading ratio. Looser than interface text by design.
  static const double leading = 1.65;

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    height: leading,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 30 / 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 19,
    height: 27 / 19,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle quote = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 27 / 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );
}
