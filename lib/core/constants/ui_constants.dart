/// UI-related constants for AURA.
class UiConstants {
  UiConstants._();

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animPageTransition = Duration(milliseconds: 350);

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 100.0;

  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationLow = 1.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Glassmorphism
  static const double glassOpacity = 0.1;
  static const double glassBlur = 20.0;
  static const double glassBorderOpacity = 0.2;

  // Grid
  static const int workspaceGridCrossAxisCount = 2;
  static const double workspaceGridChildAspectRatio = 1.1;
  static const double gridSpacing = 12.0;

  // Card
  static const double cardMinHeight = 80.0;
  static const double fileIconSize = 40.0;
  static const double graphNodeSize = 60.0;

  // Similarity Meter Colors (HSL hue values)
  static const double similarityHighHue = 140.0; // Green
  static const double similarityMedHue = 50.0; // Yellow
  static const double similarityLowHue = 0.0; // Red

  // Similarity Thresholds
  static const double similarityHighThreshold = 0.80;
  static const double similarityMedThreshold = 0.50;
}
