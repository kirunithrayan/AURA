import 'package:flutter/painting.dart';

/// Interface typography tokens for the AURA Design System.
///
/// Inter, three weights (400/500/600), an eight-tier scale for chrome. Colors
/// are applied by the consumer from the semantic layer; these styles carry
/// metrics only, so they are theme-independent.
///
/// Line heights are stored as ratios (height = line / size) so text scales
/// correctly under user font-size settings.
class AuraTypography {
  const AuraTypography._();

  /// Interface family. Bundled in Step 0; matches the `pubspec` declaration.
  static const String fontFamily = 'Inter';

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    height: 36 / 30,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 19,
    height: 26 / 19,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle micro = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w500,
  );
}
