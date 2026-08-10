import 'package:aura/core/widgets/aura_app_bar.dart';
import 'package:aura/core/widgets/aura_bottom_sheet.dart';
import 'package:aura/core/widgets/aura_card.dart';
import 'package:aura/core/widgets/aura_chip.dart';
import 'package:aura/core/widgets/file_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/aura_test_harness.dart';

void main() {
  group('Step 4 migrated components (Design System rendering)', () {
    testWidgets('component gallery - light', (tester) async {
      await pumpGolden(tester, const _Gallery());
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/components_gallery_light.png'),
      );
    });

    testWidgets('component gallery - dark', (tester) async {
      await pumpGolden(tester, const _Gallery(), brightness: Brightness.dark);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/components_gallery_dark.png'),
      );
    });

    testWidgets('app bar - light', (tester) async {
      await pumpGolden(tester, const _AppBarSpecimen());
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/components_app_bar_light.png'),
      );
    });

    testWidgets('app bar - dark', (tester) async {
      await pumpGolden(tester, const _AppBarSpecimen(), brightness: Brightness.dark);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/components_app_bar_dark.png'),
      );
    });

    testWidgets('bottom sheet - light', (tester) async {
      await pumpGolden(tester, const _SheetLauncher());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/components_bottom_sheet_light.png'),
      );
    });
  });
}

class _Gallery extends StatelessWidget {
  const _Gallery();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AuraCard(child: Text('Card content')),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  AuraChip(label: 'Rest'),
                  AuraChip(label: 'Selected', isSelected: true),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: <Widget>[
                  FileIconWidget(extension: 'pdf'),
                  SizedBox(width: 12),
                  FileIconWidget(extension: 'png'),
                  SizedBox(width: 12),
                  FileIconWidget(extension: 'xlsx'),
                ],
              ),
            ],
          ),
        ),
      );
}

class _AppBarSpecimen extends StatelessWidget {
  const _AppBarSpecimen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        appBar: AuraAppBar(
          title: 'Library',
          actions: <Widget>[Icon(Icons.add), SizedBox(width: 8), Icon(Icons.more_vert)],
        ),
        body: SizedBox.shrink(),
      );
}

class _SheetLauncher extends StatelessWidget {
  const _SheetLauncher();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => AuraBottomSheet.show<void>(
              context: context,
              builder: (BuildContext _) => const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Sheet content'),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );
}
