import 'package:flutter/material.dart';

/// Typography definitions for AURA. Uses the 'Inter' font family.
class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Inter';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: _fontFamily, fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
    displayMedium: TextStyle(fontFamily: _fontFamily, fontSize: 45, fontWeight: FontWeight.w400, letterSpacing: 0.0),
    displaySmall: TextStyle(fontFamily: _fontFamily, fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0.0),
    headlineLarge: TextStyle(fontFamily: _fontFamily, fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: 0.0),
    headlineMedium: TextStyle(fontFamily: _fontFamily, fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 0.0),
    headlineSmall: TextStyle(fontFamily: _fontFamily, fontSize: 24, fontWeight: FontWeight.w400, letterSpacing: 0.0),
    titleLarge: TextStyle(fontFamily: _fontFamily, fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0.0),
    titleMedium: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
    titleSmall: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    bodyLarge: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyMedium: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    bodySmall: TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    labelLarge: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    labelMedium: TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    labelSmall: TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  );
}
