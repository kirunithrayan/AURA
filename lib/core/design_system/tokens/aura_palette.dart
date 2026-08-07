import 'package:flutter/painting.dart';

/// Primitive color values for the AURA Design System.
///
/// LAYER 1 (primitives). These are raw, theme-INDEPENDENT values named by
/// appearance, never by role. They carry no meaning on their own.
///
/// INTERNAL: this class is deliberately NOT exported from `design_tokens.dart`.
/// Widgets and features must never reference a primitive directly — they consume
/// the semantic layer ([AuraColors]) through the [AuraTokens] theme extension so
/// that light/dark resolution stays correct. Reaching a primitive directly is
/// how a widget silently breaks dark mode.
class AuraPalette {
  const AuraPalette._();

  // Warm neutral ramp (light).
  static const Color n0 = Color(0xFFFFFFFF);
  static const Color n50 = Color(0xFFFBFAF8);
  static const Color n100 = Color(0xFFF5F3EF);
  static const Color n200 = Color(0xFFEAE7E1);
  static const Color n300 = Color(0xFFDCD8D0);
  static const Color n400 = Color(0xFFBFBAB1);
  static const Color n500 = Color(0xFF95908A);
  static const Color n600 = Color(0xFF6B6862);
  static const Color n700 = Color(0xFF4A4844);
  static const Color n900 = Color(0xFF1C1C1F);

  // Warm neutral ramp (dark).
  static const Color d0 = Color(0xFF0E0E11);
  static const Color d50 = Color(0xFF16161A);
  static const Color d100 = Color(0xFF1C1C21);
  static const Color d200 = Color(0xFF24242A);
  static const Color d250 = Color(0xFF2A2A31);
  static const Color d300 = Color(0xFF2F2F36);
  static const Color d400 = Color(0xFF43434B);
  static const Color d500 = Color(0xFF63636C);
  static const Color d600 = Color(0xFF8A8A93);
  static const Color d700 = Color(0xFFB0AFB6);
  static const Color d900 = Color(0xFFE8E6E1);

  // Ink blue (action / interactive).
  static const Color blue50 = Color(0xFFEAF0FB);
  static const Color blue60 = Color(0xFF2A4E9B);
  static const Color blue70 = Color(0xFF1F3B78);
  static const Color blue30OnDark = Color(0xFF8AAEF0);
  static const Color blueSubtleDark = Color(0xFF1B2439);
  static const Color bluePressedDark = Color(0xFFA6C2F5);
  static const Color onActionDark = Color(0xFF0F1728);

  // Status (muted, never candy).
  static const Color green60 = Color(0xFF2F7D5A);
  static const Color green40 = Color(0xFF6DBF9A);
  static const Color amber60 = Color(0xFFA8701F);
  static const Color amber40 = Color(0xFFDDA657);
  static const Color red60 = Color(0xFFB3453A);
  static const Color red40 = Color(0xFFE28B80);

  // Reading (sepia surface, an axis independent of app theme).
  static const Color sepiaSurface = Color(0xFFF4EDDF);
  static const Color sepiaInk = Color(0xFF3A3229);
  static const Color sepiaInkSecondary = Color(0xFF5C5346);

  // Course identity hues (light).
  static const Color slateLight = Color(0xFF4A6785);
  static const Color sageLight = Color(0xFF5A7A5E);
  static const Color clayLight = Color(0xFF9B6146);
  static const Color plumLight = Color(0xFF7A5480);
  static const Color ochreLight = Color(0xFF96762F);
  static const Color tealLight = Color(0xFF3E7377);
  static const Color roseLight = Color(0xFF95566A);
  static const Color mossLight = Color(0xFF6B7440);

  // Course identity hues (dark).
  static const Color slateDark = Color(0xFF8FAAC6);
  static const Color sageDark = Color(0xFF93B596);
  static const Color clayDark = Color(0xFFCE9A7C);
  static const Color plumDark = Color(0xFFB694BB);
  static const Color ochreDark = Color(0xFFCBAC63);
  static const Color tealDark = Color(0xFF84B2B5);
  static const Color roseDark = Color(0xFFC795A4);
  static const Color mossDark = Color(0xFFA9B27B);
}
