import 'package:aura/core/widgets/aura_app_bar.dart';
import 'package:aura/core/widgets/aura_button.dart';
import 'package:aura/core/widgets/aura_course_grid_section.dart';
import 'package:aura/core/widgets/aura_course_tile.dart';
import 'package:aura/core/widgets/aura_document_tile.dart';
import 'package:aura/core/widgets/aura_empty_state.dart';
import 'package:aura/core/widgets/aura_icon_button.dart';
import 'package:aura/core/widgets/aura_monogram.dart';
import 'package:aura/core/widgets/aura_recent_section.dart';
import 'package:aura/core/widgets/aura_section_header.dart';
import 'package:aura/core/widgets/aura_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/aura_test_harness.dart';

void _noop() {}

Future<void> _match(WidgetTester tester, String name) => expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );

void main() {
  group('Step 5 components (Design System rendering)', () {
    testWidgets('buttons - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _ButtonsSpecimen()));
      await _match(tester, 'step5_buttons_light');
    });
    testWidgets('buttons - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _ButtonsSpecimen()),
          brightness: Brightness.dark);
      await _match(tester, 'step5_buttons_dark');
    });
    testWidgets('buttons - 200%', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _ButtonsSpecimen()),
          textScale: 2.0);
      await _match(tester, 'step5_buttons_textscale200');
    });

    testWidgets('icon buttons - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _IconButtonsSpecimen()));
      await _match(tester, 'step5_icon_buttons_light');
    });
    testWidgets('icon buttons - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _IconButtonsSpecimen()),
          brightness: Brightness.dark);
      await _match(tester, 'step5_icon_buttons_dark');
    });

    testWidgets('monogram palette - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _MonogramSpecimen()));
      await _match(tester, 'step5_monogram_light');
    });
    testWidgets('monogram palette - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _MonogramSpecimen()),
          brightness: Brightness.dark);
      await _match(tester, 'step5_monogram_dark');
    });

    testWidgets('section header - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _SectionHeaderSpecimen()));
      await _match(tester, 'step5_section_header_light');
    });
    testWidgets('section header - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _SectionHeaderSpecimen()),
          brightness: Brightness.dark);
      await _match(tester, 'step5_section_header_dark');
    });

    testWidgets('document tiles - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _DocumentTilesSpecimen()));
      await _match(tester, 'step5_document_tiles_light');
    });
    testWidgets('document tiles - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _DocumentTilesSpecimen()),
          brightness: Brightness.dark);
      await _match(tester, 'step5_document_tiles_dark');
    });
    testWidgets('document tiles - 200%', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _DocumentTilesSpecimen()),
          textScale: 2.0);
      await _match(tester, 'step5_document_tiles_textscale200');
    });

    testWidgets('course tiles - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _CourseTilesSpecimen()));
      await _match(tester, 'step5_course_tiles_light');
    });
    testWidgets('course tiles - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _CourseTilesSpecimen()),
          brightness: Brightness.dark);
      await _match(tester, 'step5_course_tiles_dark');
    });
    testWidgets('course tiles - 200%', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _CourseTilesSpecimen()),
          textScale: 2.0);
      await _match(tester, 'step5_course_tiles_textscale200');
    });

    testWidgets('course grid section - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _CourseGridSpecimen()));
      await _match(tester, 'step5_course_grid_light');
    });
    testWidgets('course grid section - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _CourseGridSpecimen()),
          brightness: Brightness.dark);
      await _match(tester, 'step5_course_grid_dark');
    });

    testWidgets('recent section - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _RecentSpecimen()));
      await _match(tester, 'step5_recent_light');
    });
    testWidgets('recent section - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _RecentSpecimen()),
          brightness: Brightness.dark);
      await _match(tester, 'step5_recent_dark');
    });
    testWidgets('recent section - 200%', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _RecentSpecimen()),
          textScale: 2.0);
      await _match(tester, 'step5_recent_textscale200');
    });

    testWidgets('empty state with action - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _EmptyWithActionSpecimen());
      await _match(tester, 'step5_empty_action_light');
    });
    testWidgets('empty state with action - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _EmptyWithActionSpecimen(),
          brightness: Brightness.dark);
      await _match(tester, 'step5_empty_action_dark');
    });
    testWidgets('empty state with action - 200%', (WidgetTester tester) async {
      await pumpGolden(tester, const _EmptyWithActionSpecimen(), textScale: 2.0);
      await _match(tester, 'step5_empty_action_textscale200');
    });

    testWidgets('empty state no action - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _EmptyNoActionSpecimen());
      await _match(tester, 'step5_empty_plain_light');
    });
    testWidgets('empty state no action - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _EmptyNoActionSpecimen(),
          brightness: Brightness.dark);
      await _match(tester, 'step5_empty_plain_dark');
    });

    testWidgets('app bar - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _AppBarSpecimen());
      await _match(tester, 'step5_app_bar_light');
    });
    testWidgets('app bar - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _AppBarSpecimen(),
          brightness: Brightness.dark);
      await _match(tester, 'step5_app_bar_dark');
    });
    testWidgets('app bar - 200%', (WidgetTester tester) async {
      await pumpGolden(tester, const _AppBarSpecimen(), textScale: 2.0);
      await _match(tester, 'step5_app_bar_textscale200');
    });

    testWidgets('sheet - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _SheetLauncher());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await _match(tester, 'step5_sheet_light');
    });
    testWidgets('sheet - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _SheetLauncher(),
          brightness: Brightness.dark);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await _match(tester, 'step5_sheet_dark');
    });
  });
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Align(
              alignment: Alignment.topLeft,
              child: child,
            ),
          ),
        ),
      );
}

class _ButtonsSpecimen extends StatelessWidget {
  const _ButtonsSpecimen();

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AuraButton(
            label: 'Primary',
            variant: AuraButtonVariant.primary,
            icon: Icons.add,
            onPressed: _noop,
          ),
          SizedBox(height: 12),
          AuraButton(label: 'Secondary', onPressed: _noop),
          SizedBox(height: 12),
          AuraButton(
            label: 'Text',
            variant: AuraButtonVariant.text,
            onPressed: _noop,
          ),
          SizedBox(height: 12),
          AuraButton(
            label: 'Disabled',
            variant: AuraButtonVariant.primary,
            onPressed: null,
          ),
        ],
      );
}

class _IconButtonsSpecimen extends StatelessWidget {
  const _IconButtonsSpecimen();

  @override
  Widget build(BuildContext context) => const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AuraIconButton(icon: Icons.search, tooltip: 'Search', onPressed: _noop),
          AuraIconButton(icon: Icons.add, tooltip: 'Add', onPressed: _noop),
          AuraIconButton(
            icon: Icons.more_vert,
            tooltip: 'More',
            onPressed: null,
          ),
        ],
      );
}

class _MonogramSpecimen extends StatelessWidget {
  const _MonogramSpecimen();

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          for (final AuraCourseColor color in AuraCourseColor.values)
            AuraMonogram(label: color.name, color: color),
        ],
      );
}

class _SectionHeaderSpecimen extends StatelessWidget {
  const _SectionHeaderSpecimen();

  @override
  Widget build(BuildContext context) => const AuraSectionHeader(
        title: 'Courses',
        action: AuraButton(
          label: 'See all',
          variant: AuraButtonVariant.text,
          onPressed: _noop,
        ),
      );
}

class _DocumentTilesSpecimen extends StatelessWidget {
  const _DocumentTilesSpecimen();

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AuraDocumentTile(
            title: 'Lecture Notes Week 1',
            subtitle: 'Physics',
            fileType: AuraFileType.pdf,
            onTap: _noop,
          ),
          SizedBox(height: 12),
          AuraDocumentTile(
            title: 'Reaction Diagram',
            subtitle: 'Chemistry',
            fileType: AuraFileType.image,
            variant: AuraDocumentTileVariant.gridCell,
            onTap: _noop,
          ),
          SizedBox(height: 12),
          AuraDocumentTile(
            title: 'A search result with a long title that wraps onto two lines',
            subtitle: 'Biology',
            fileType: AuraFileType.doc,
            variant: AuraDocumentTileVariant.searchResult,
            onTap: _noop,
          ),
          SizedBox(height: 12),
          AuraDocumentTile(
            title: 'Selected recent file',
            fileType: AuraFileType.txt,
            variant: AuraDocumentTileVariant.recent,
            selected: true,
            onTap: _noop,
          ),
        ],
      );
}

class _CourseTilesSpecimen extends StatelessWidget {
  const _CourseTilesSpecimen();

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AuraCourseTile(
            name: 'Organic Chemistry',
            color: AuraCourseColor.clay,
            onTap: _noop,
          ),
          SizedBox(height: 12),
          AuraCourseTile(
            name: 'Linear Algebra',
            color: AuraCourseColor.slate,
            variant: AuraCourseTileVariant.list,
            onTap: _noop,
          ),
        ],
      );
}

class _CourseGridSpecimen extends StatelessWidget {
  const _CourseGridSpecimen();

  @override
  Widget build(BuildContext context) => const AuraCourseGridSection(
        header: AuraSectionHeader(title: 'Courses'),
        courses: <AuraCourseData>[
          AuraCourseData(name: 'Physics', color: AuraCourseColor.teal, onTap: _noop),
          AuraCourseData(name: 'History', color: AuraCourseColor.ochre, onTap: _noop),
          AuraCourseData(name: 'Biology', color: AuraCourseColor.sage, onTap: _noop),
        ],
      );
}

class _RecentSpecimen extends StatelessWidget {
  const _RecentSpecimen();

  @override
  Widget build(BuildContext context) => const AuraRecentSection(
        header: AuraSectionHeader(title: 'Recent'),
        documents: <AuraRecentDocumentData>[
          AuraRecentDocumentData(
            title: 'Notes.pdf',
            subtitle: 'Physics',
            fileType: AuraFileType.pdf,
            onTap: _noop,
          ),
          AuraRecentDocumentData(
            title: 'Essay.docx',
            subtitle: 'English',
            fileType: AuraFileType.doc,
            onTap: _noop,
          ),
        ],
      );
}

class _EmptyWithActionSpecimen extends StatelessWidget {
  const _EmptyWithActionSpecimen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: AuraEmptyState(
          title: 'No documents yet',
          message: 'Add your first file to get started.',
          action: AuraButton(
            label: 'Add file',
            variant: AuraButtonVariant.primary,
            onPressed: _noop,
          ),
        ),
      );
}

class _EmptyNoActionSpecimen extends StatelessWidget {
  const _EmptyNoActionSpecimen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: AuraEmptyState(
          title: 'Nothing here',
          message: 'This course has no files.',
        ),
      );
}

class _AppBarSpecimen extends StatelessWidget {
  const _AppBarSpecimen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        appBar: AuraAppBar(
          title: 'Library',
          actions: <Widget>[
            AuraIconButton(icon: Icons.search, tooltip: 'Search', onPressed: _noop),
          ],
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
            onPressed: () => AuraSheet.show<void>(
              context: context,
              title: 'Sort by',
              child: const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text('Sheet content'),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );
}
