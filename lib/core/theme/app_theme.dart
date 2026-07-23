import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import '../constants/ui_constants.dart';

/// The main theme configuration for AURA.
class AppTheme {
  AppTheme._();

  /// Light Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        background: AppColors.backgroundLight,
        onBackground: AppColors.onBackgroundLight,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.onSurfaceLight,
        surfaceVariant: AppColors.surfaceVariantLight,
        onSurfaceVariant: AppColors.onSurfaceVariantLight,
        outline: AppColors.outlineLight,
      ),
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.onBackgroundLight,
        elevation: UiConstants.elevationNone,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceLight,
        elevation: UiConstants.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(UiConstants.radiusXLarge)),
        ),
      ),
    );
  }

  /// Dark Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primaryContainer, // Lighter primary for dark mode
        onPrimary: AppColors.onPrimaryContainer,
        primaryContainer: AppColors.primary,
        onPrimaryContainer: AppColors.onPrimary,
        secondary: AppColors.secondaryContainer,
        onSecondary: AppColors.onSecondaryContainer,
        secondaryContainer: AppColors.secondary,
        onSecondaryContainer: AppColors.onSecondary,
        tertiary: AppColors.tertiaryContainer,
        onTertiary: AppColors.onTertiaryContainer,
        tertiaryContainer: AppColors.tertiary,
        onTertiaryContainer: AppColors.onTertiary,
        error: AppColors.errorContainer,
        onError: AppColors.onErrorContainer,
        errorContainer: AppColors.error,
        onErrorContainer: AppColors.onError,
        background: AppColors.backgroundDark,
        onBackground: AppColors.onBackgroundDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
        surfaceVariant: AppColors.surfaceVariantDark,
        onSurfaceVariant: AppColors.onSurfaceVariantDark,
        outline: AppColors.outlineDark,
      ),
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.onBackgroundDark,
        elevation: UiConstants.elevationNone,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceVariantDark,
        elevation: UiConstants.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(UiConstants.radiusXLarge)),
        ),
      ),
    );
  }
}
