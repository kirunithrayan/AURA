/// Spacing tokens for the AURA Design System.
///
/// One 4pt rhythm for the whole product. Theme-independent, so accessed
/// statically. The primitive `s*` scale is the raw ramp; the semantic aliases
/// name the roles used by the approved layout specs (screen margin, section
/// gap, etc.). Nothing off this scale should appear in a layout.
class AuraSpacing {
  const AuraSpacing._();

  // Primitive 4pt scale.
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s64 = 64;

  // Semantic layout aliases.
  static const double screenMargin = s20;
  static const double sectionGap = s32;
  static const double groupGap = s24;

  // Semantic component aliases.
  static const double componentPadding = s16;
  static const double componentGap = s12;
  static const double gapTight = s8;
  static const double gapMicro = s4;

  // Semantic reading aliases.
  static const double readingMargin = s24;
  static const double readingParagraph = s16;
  static const double readingHeadingAbove = s32;
  static const double readingHeadingBelow = s12;
  static const double readingBottomPad = s48;
}
