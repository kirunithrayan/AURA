/// AURA Design Token Foundation — public surface.
///
/// The single source of truth for the approved Design System's visual values.
/// Import this barrel to consume tokens; the primitive palette
/// (`tokens/aura_palette.dart`) is deliberately NOT exported, so widgets can only
/// reach the semantic layer and dark mode cannot be broken by accident.
///
/// Theme-dependent tokens (colors) resolve through [AuraTokens] via the theme;
/// theme-independent scales are const classes accessed statically.
library;

export 'tokens/aura_colors.dart';
export 'tokens/aura_elevation.dart';
export 'tokens/aura_metrics.dart';
export 'tokens/aura_motion.dart';
export 'tokens/aura_radius.dart';
export 'tokens/aura_reading.dart';
export 'tokens/aura_spacing.dart';
export 'tokens/aura_tokens.dart';
export 'tokens/aura_typography.dart';
