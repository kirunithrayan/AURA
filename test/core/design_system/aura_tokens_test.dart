import 'package:aura/core/design_system/design_tokens.dart';
import 'package:aura/core/extensions/context_extensions.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuraColors', () {
    test('light and dark map to distinct, on-spec semantic values', () {
      expect(AuraColors.light.actionPrimary, const Color(0xFF2A4E9B));
      expect(AuraColors.dark.actionPrimary, const Color(0xFF8AAEF0));
      expect(AuraColors.light.surfaceReading, const Color(0xFFFBFAF8));
      expect(AuraColors.dark.surfaceReading, const Color(0xFF16161A));
      expect(AuraColors.light.contentPrimary, const Color(0xFF1C1C1F));
      expect(AuraColors.dark.contentPrimary, const Color(0xFFE8E6E1));
    });

    test('dark contentPrimary is not pure white (halation guard)', () {
      expect(AuraColors.dark.contentPrimary, isNot(const Color(0xFFFFFFFF)));
    });
  });

  group('AuraTokens', () {
    test('copyWith replaces the color bundle', () {
      final AuraTokens t = AuraTokens.light.copyWith(colors: AuraColors.dark);
      expect(t.colors, AuraColors.dark);
    });

    test('lerp returns endpoints at 0 and 1 and interpolates the midpoint', () {
      const AuraTokens a = AuraTokens.light;
      const AuraTokens b = AuraTokens.dark;
      expect(a.lerp(b, 0).colors.contentPrimary, a.colors.contentPrimary);
      expect(a.lerp(b, 1).colors.contentPrimary, b.colors.contentPrimary);
      final Color mid = a.lerp(b, 0.5).colors.contentPrimary;
      expect(mid, isNot(a.colors.contentPrimary));
      expect(mid, isNot(b.colors.contentPrimary));
    });

    test('lerp with a null other returns this', () {
      expect(AuraTokens.light.lerp(null, 0.5), same(AuraTokens.light));
    });
  });

  group('Theme integration', () {
    testWidgets('resolves from context in the light theme', (tester) async {
      late AuraTokens resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (BuildContext context) {
              resolved = context.tokens;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved.colors.surfaceBackground, const Color(0xFFF5F3EF));
    });

    testWidgets('resolves from context in the dark theme', (tester) async {
      late AuraTokens resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (BuildContext context) {
              resolved = context.tokens;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved.colors.surfaceBackground, const Color(0xFF1C1C21));
    });
  });

  group('Theme-independent scales are present and on-spec', () {
    test('spacing, radius, typography, reading, motion', () {
      expect(AuraSpacing.screenMargin, 20);
      expect(AuraSpacing.sectionGap, 32);
      expect(AuraSpacing.componentGap, 12);
      expect(AuraRadius.md, 12);
      expect(AuraRadius.full, 999);
      expect(AuraTypography.fontFamily, 'Inter');
      expect(AuraTypography.titleLg.fontSize, 24);
      expect(AuraReading.fontFamily, 'Source Serif 4');
      expect(AuraReading.leading, 1.65);
      expect(AuraMotion.standard, const Duration(milliseconds: 200));
    });

    test('elevation, borders, icon, layout, opacity, reading colors', () {
      expect(AuraElevation.flat, isEmpty);
      expect(AuraElevation.card, isEmpty);
      expect(AuraElevation.overlay, hasLength(1));
      expect(AuraElevation.modal, hasLength(1));
      expect(AuraBorders.hairline, 1);
      expect(AuraBorders.focus, 2);
      expect(AuraIconTokens.sizeMd, 24);
      expect(AuraIconTokens.stroke, 1.75);
      expect(AuraLayout.readingContainerMax, 680);
      expect(AuraLayout.touchTargetMin, 48);
      expect(AuraOpacity.tint, 0.16);
      expect(AuraOpacity.scrim, 0.32);
      expect(AuraReadingColors.night.surface, const Color(0xFF16161A));
    });
  });
}
