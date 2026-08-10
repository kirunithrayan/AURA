import 'package:aura/core/widgets/aura_course_grid_section.dart';
import 'package:aura/core/widgets/aura_document_tile.dart';
import 'package:aura/core/widgets/aura_monogram.dart';
import 'package:aura/core/widgets/aura_recent_section.dart';
import 'package:aura/features/home/presentation/widgets/library_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/aura_test_harness.dart';

void _noop() {}

Future<void> _match(WidgetTester tester, String name) => expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );

/// Fixed sample data so the Library renders deterministically without touching
/// providers, the database, or the file system.
const List<AuraCourseData> _courses = <AuraCourseData>[
  AuraCourseData(name: 'Organic Chemistry', color: AuraCourseColor.clay, onTap: _noop),
  AuraCourseData(name: 'Linear Algebra', color: AuraCourseColor.slate, onTap: _noop),
  AuraCourseData(name: 'World History', color: AuraCourseColor.ochre, onTap: _noop),
];

const List<AuraRecentDocumentData> _recent = <AuraRecentDocumentData>[
  AuraRecentDocumentData(
    title: 'Lecture Notes Week 1.pdf',
    subtitle: 'Organic Chemistry',
    fileType: AuraFileType.pdf,
    onTap: _noop,
  ),
  AuraRecentDocumentData(
    title: 'Eigenvalues and eigenvectors, worked examples.docx',
    subtitle: 'Linear Algebra',
    fileType: AuraFileType.doc,
    onTap: _noop,
  ),
];

class _PopulatedLibrary extends StatelessWidget {
  const _PopulatedLibrary();

  @override
  Widget build(BuildContext context) => const LibraryView(
        courses: _courses,
        recentDocuments: _recent,
      );
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) => const LibraryView(
        courses: <AuraCourseData>[],
        recentDocuments: <AuraRecentDocumentData>[],
      );
}

void main() {
  group('Library screen (Step 6, Direction B)', () {
    testWidgets('populated - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _PopulatedLibrary());
      await _match(tester, 'library_populated_light');
    });

    testWidgets('populated - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _PopulatedLibrary(),
          brightness: Brightness.dark);
      await _match(tester, 'library_populated_dark');
    });

    testWidgets('empty - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _EmptyLibrary());
      await _match(tester, 'library_empty_light');
    });

    testWidgets('empty - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _EmptyLibrary(),
          brightness: Brightness.dark);
      await _match(tester, 'library_empty_dark');
    });

    testWidgets('populated - 200% text scale', (WidgetTester tester) async {
      await pumpGolden(tester, const _PopulatedLibrary(), textScale: 2.0);
      await _match(tester, 'library_populated_textscale200');
    });
  });
}
