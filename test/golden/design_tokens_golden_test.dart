import 'package:aura/core/design_system/design_tokens.dart';
import 'package:aura/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/aura_test_harness.dart';

void main() {
  group('Design token golden proof', () {
    testWidgets('token sheet renders deterministically in light', (tester) async {
      await pumpGolden(tester, const _TokenSheet());
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/design_tokens_light.png'),
      );
    });

    testWidgets('token sheet renders deterministically in dark', (tester) async {
      await pumpGolden(tester, const _TokenSheet(), brightness: Brightness.dark);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/design_tokens_dark.png'),
      );
    });
  });
}

/// A minimal specimen that exercises the token foundation end to end:
/// theme-resolved colors ([AuraTokens] via `context.tokens`), the interface
/// scale (Inter), the reading scale (Source Serif 4), spacing, and radius.
/// Its only purpose is to prove the golden harness renders tokens
/// deterministically; it is not production UI.
class _TokenSheet extends StatelessWidget {
  const _TokenSheet();

  static const List<Color Function(AuraColors)> _courses =
      <Color Function(AuraColors)>[
    _slate, _sage, _clay, _plum, _ochre, _teal, _rose, _moss,
  ];

  static Color _slate(AuraColors c) => c.courseSlate;
  static Color _sage(AuraColors c) => c.courseSage;
  static Color _clay(AuraColors c) => c.courseClay;
  static Color _plum(AuraColors c) => c.coursePlum;
  static Color _ochre(AuraColors c) => c.courseOchre;
  static Color _teal(AuraColors c) => c.courseTeal;
  static Color _rose(AuraColors c) => c.courseRose;
  static Color _moss(AuraColors c) => c.courseMoss;

  @override
  Widget build(BuildContext context) {
    final AuraColors colors = context.tokens.colors;
    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: Padding(
        padding: const EdgeInsets.all(AuraSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Library',
              style: AuraTypography.titleLg.copyWith(color: colors.contentPrimary),
            ),
            const SizedBox(height: AuraSpacing.gapMicro),
            Text(
              'Interface text in Inter.',
              style: AuraTypography.body.copyWith(color: colors.contentSecondary),
            ),
            const SizedBox(height: AuraSpacing.sectionGap),
            Text(
              'Reading text in Source Serif 4. The quick brown fox jumps over '
              'the lazy dog.',
              style: AuraReading.body.copyWith(color: colors.contentPrimary),
            ),
            const SizedBox(height: AuraSpacing.sectionGap),
            Wrap(
              spacing: AuraSpacing.componentGap,
              runSpacing: AuraSpacing.componentGap,
              children: <Widget>[
                for (final Color Function(AuraColors) course in _courses)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: course(colors),
                      borderRadius: BorderRadius.circular(AuraRadius.md),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
