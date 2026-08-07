import 'package:flutter/material.dart';

import 'aura_colors.dart';

/// The theme-resolved bundle of AURA design tokens, delivered via Flutter's
/// [ThemeExtension] mechanism.
///
/// Only *theme-dependent* tokens live here (colors). Theme-INDEPENDENT scales
/// (spacing, radius, typography, motion, etc.) are plain const classes accessed
/// statically, because they do not change between light and dark.
///
/// Access from a widget via `Theme.of(context).extension<AuraTokens>()!`, or the
/// `context.tokens` convenience getter in `context_extensions.dart`.
///
/// Registered in [AppTheme] but not yet consumed by feature code; adoption is
/// staged across later migration steps.
class AuraTokens extends ThemeExtension<AuraTokens> {
  const AuraTokens({required this.colors});

  /// Light-theme token bundle.
  static const AuraTokens light = AuraTokens(colors: AuraColors.light);

  /// Dark-theme token bundle.
  static const AuraTokens dark = AuraTokens(colors: AuraColors.dark);

  /// Semantic color roles for the active theme.
  final AuraColors colors;

  @override
  AuraTokens copyWith({AuraColors? colors}) =>
      AuraTokens(colors: colors ?? this.colors);

  @override
  AuraTokens lerp(covariant AuraTokens? other, double t) {
    if (other == null) {
      return this;
    }
    return AuraTokens(colors: AuraColors.lerp(colors, other.colors, t));
  }
}
