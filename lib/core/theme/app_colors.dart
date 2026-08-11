import 'package:flutter/material.dart';

/// Centralized color palette for AURA.
/// Uses a Deep Purple / Indigo primary with Teal accents.
class AppColors {
  AppColors._();

  // Primary Colors (Deep Purple / Indigo)
  static const Color primary = Color(0xFF6750A4);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color onPrimaryContainer = Color(0xFF21005D);

  // Secondary Colors (Teal Accents)
  static const Color secondary = Color(0xFF006A60);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF74F8E5);
  static const Color onSecondaryContainer = Color(0xFF00201C);

  // Tertiary Colors (Soft Amber/Orange for highlights)
  static const Color tertiary = Color(0xFF7D5260);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFD8E4);
  static const Color onTertiaryContainer = Color(0xFF31111D);

  // Error Colors
  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);

  // Background & Surface (Light)
  static const Color backgroundLight = Color(0xFFFFFBFE);
  static const Color onBackgroundLight = Color(0xFF1C1B1F);
  static const Color surfaceLight = Color(0xFFFFFBFE);
  static const Color onSurfaceLight = Color(0xFF1C1B1F);
  static const Color surfaceVariantLight = Color(0xFFE7E0EC);
  static const Color onSurfaceVariantLight = Color(0xFF49454F);

  // Background & Surface (Dark)
  static const Color backgroundDark = Color(0xFF1C1B1F);
  static const Color onBackgroundDark = Color(0xFFE6E1E5);
  static const Color surfaceDark = Color(0xFF1C1B1F);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color surfaceVariantDark = Color(0xFF49454F);
  static const Color onSurfaceVariantDark = Color(0xFFCAC4D0);

  // Outline
  static const Color outlineLight = Color(0xFF79747E);
  static const Color outlineDark = Color(0xFF938F99);

  // Compatibility aliases
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color textPrimary = onSurfaceLight;
  static const Color textSecondary = onSurfaceVariantLight;
  static const Color divider = outlineLight;
}
