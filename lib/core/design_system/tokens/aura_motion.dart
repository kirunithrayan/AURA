import 'package:flutter/animation.dart';

/// Motion tokens for the AURA Design System.
///
/// Motion explains state or preserves continuity; it never decorates. Durations
/// are capped at 300ms and there are no spring/bounce curves by design — a value
/// that has no token cannot be reached without breaking the no-literals rule.
class AuraMotion {
  const AuraMotion._();

  // Durations.
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration standard = Duration(milliseconds: 200);
  static const Duration deliberate = Duration(milliseconds: 280);

  /// Reduced-motion resolution for positional animation.
  static const Duration reduced = Duration.zero;

  /// Skeleton opacity cycle (a single slow pulse, never a shimmer sweep).
  static const Duration skeletonPulse = Duration(milliseconds: 1200);

  // Curves.
  static const Curve standardCurve = Cubic(0.2, 0, 0, 1);
  static const Curve easeOut = Curves.easeOut;
}
