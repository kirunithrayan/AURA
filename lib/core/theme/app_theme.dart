import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import '../constants/ui_constants.dart';
import '../design_system/design_tokens.dart';

/// The main theme configuration for AURA.
class AppTheme {
  AppTheme._();

  /// Light Theme Data
  static ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      // Design Token Foundation (Step 1). Additive: registered so tokens are
      // resolvable via context; existing colorScheme/textTheme are unchanged.
      extensions: const <ThemeExtension<dynamic>>[AuraTokens.light],
      // Step 3 (Theme Migration). Per approved Design System governance:
      //  - Roles the DS explicitly defines are mapped to design tokens (below).
      //  - Roles the DS does NOT define (containers, secondary, tertiary,
      //    surface tones, inverse, fixed) INTENTIONALLY remain at the existing
      //    Material implementation, pending any future Design System revision.
      //    Do not invent, derive, or "improve" these — that is a DS decision.
      // Not const: token roles are field accesses on AuraColors, not consts.
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AuraColors.light.actionPrimary, // DIRECT: action.primary
        onPrimary: AuraColors.light.contentOnAction, // DIRECT: content.onAction
        primaryContainer: AppColors.primaryContainer, // UNDEFINED (legacy)
        onPrimaryContainer: AppColors.onPrimaryContainer, // UNDEFINED (legacy)
        secondary: AppColors.secondary, // UNDEFINED (legacy)
        onSecondary: AppColors.onSecondary, // UNDEFINED (legacy)
        secondaryContainer: AppColors.secondaryContainer, // UNDEFINED (legacy)
        onSecondaryContainer: AppColors.onSecondaryContainer, // UNDEFINED (legacy)
        tertiary: AppColors.tertiary, // UNDEFINED (legacy)
        onTertiary: AppColors.onTertiary, // UNDEFINED (legacy)
        tertiaryContainer: AppColors.tertiaryContainer, // UNDEFINED (legacy)
        onTertiaryContainer: AppColors.onTertiaryContainer, // UNDEFINED (legacy)
        error: AuraColors.light.statusError, // DIRECT: status.error
        onError: AppColors.onError, // UNDEFINED (legacy)
        errorContainer: AppColors.errorContainer, // UNDEFINED (legacy)
        onErrorContainer: AppColors.onErrorContainer, // UNDEFINED (legacy)
        surface: AppColors.surfaceLight, // UNDEFINED (legacy)
        onSurface: AuraColors.light.contentPrimary, // DIRECT: content.primary
        surfaceContainerHighest: AppColors.surfaceVariantLight, // UNDEFINED (legacy)
        onSurfaceVariant: AuraColors.light.contentSecondary, // DIRECT: content.secondary
        outline: AuraColors.light.borderDefault, // DIRECT: border.default
      ),
      // Step 3: the one explicitly-defined typography mapping. The DS `headline`
      // tier is an explicit alias of `title.lg` (Design System §5.2), so the
      // three M3 headline slots adopt it. Every other TextTheme slot has no
      // DS-defined M3 correspondence and intentionally remains at the existing
      // Material implementation, pending any future Design System revision.
      textTheme: AppTypography.textTheme.copyWith(
        headlineLarge: AuraTypography.titleLg,
        headlineMedium: AuraTypography.titleLg,
        headlineSmall: AuraTypography.titleLg,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.onBackgroundLight,
        elevation: UiConstants.elevationNone,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
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

  /// Dark Theme Data
  static ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      // Design Token Foundation (Step 1). Additive: registered so tokens are
      // resolvable via context; existing colorScheme/textTheme are unchanged.
      extensions: const <ThemeExtension<dynamic>>[AuraTokens.dark],
      // Step 3 (Theme Migration): DS-defined roles mapped to tokens; DS-undefined
      // roles intentionally kept at the existing Material implementation. See the
      // light theme for the full governance note.
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: AuraColors.dark.actionPrimary, // DIRECT: action.primary
        onPrimary: AuraColors.dark.contentOnAction, // DIRECT: content.onAction
        primaryContainer: AppColors.primary, // UNDEFINED (legacy)
        onPrimaryContainer: AppColors.onPrimary, // UNDEFINED (legacy)
        secondary: AppColors.secondaryContainer, // UNDEFINED (legacy)
        onSecondary: AppColors.onSecondaryContainer, // UNDEFINED (legacy)
        secondaryContainer: AppColors.secondary, // UNDEFINED (legacy)
        onSecondaryContainer: AppColors.onSecondary, // UNDEFINED (legacy)
        tertiary: AppColors.tertiaryContainer, // UNDEFINED (legacy)
        onTertiary: AppColors.onTertiaryContainer, // UNDEFINED (legacy)
        tertiaryContainer: AppColors.tertiary, // UNDEFINED (legacy)
        onTertiaryContainer: AppColors.onTertiary, // UNDEFINED (legacy)
        error: AuraColors.dark.statusError, // DIRECT: status.error
        onError: AppColors.onErrorContainer, // UNDEFINED (legacy)
        errorContainer: AppColors.error, // UNDEFINED (legacy)
        onErrorContainer: AppColors.onError, // UNDEFINED (legacy)
        surface: AppColors.surfaceDark, // UNDEFINED (legacy)
        onSurface: AuraColors.dark.contentPrimary, // DIRECT: content.primary
        surfaceContainerHighest: AppColors.surfaceVariantDark, // UNDEFINED (legacy)
        onSurfaceVariant: AuraColors.dark.contentSecondary, // DIRECT: content.secondary
        outline: AuraColors.dark.borderDefault, // DIRECT: border.default
      ),
      // Step 3: the one explicitly-defined typography mapping. The DS `headline`
      // tier is an explicit alias of `title.lg` (Design System §5.2), so the
      // three M3 headline slots adopt it. Every other TextTheme slot has no
      // DS-defined M3 correspondence and intentionally remains at the existing
      // Material implementation, pending any future Design System revision.
      textTheme: AppTypography.textTheme.copyWith(
        headlineLarge: AuraTypography.titleLg,
        headlineMedium: AuraTypography.titleLg,
        headlineSmall: AuraTypography.titleLg,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.onBackgroundDark,
        elevation: UiConstants.elevationNone,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
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
