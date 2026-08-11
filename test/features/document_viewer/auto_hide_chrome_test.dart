import 'package:aura/core/design_system/design_tokens.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/document_viewer/presentation/widgets/base_viewer_screen.dart';
import 'package:aura/features/document_viewer/presentation/widgets/viewer_bottom_toolbar.dart';
import 'package:aura/features/document_viewer/presentation/widgets/viewer_toolbar.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Step 8 auto-hide-on-scroll.
///
/// Auto-hide is an approved implementation decision, not a blueprint-specified
/// behaviour: hide after scrolling down past `AuraLayout.appBarHeight`, restore
/// on any upward scroll, text/DOCX only.
WorkspaceFile _file(String extension) => WorkspaceFile(
      id: 'f1',
      workspaceId: 'ws1',
      fileName: 'notes.$extension',
      filePath: '/tmp/notes.$extension',
      extension: extension,
      createdAt: 0,
      modifiedAt: 0,
      importedAt: 0,
    );

Widget _harness(WorkspaceFile file) => ProviderScope(
      child: MaterialApp(
        // The toolbars resolve design tokens through the AuraTokens extension,
        // which only the production theme registers.
        theme: AppTheme.lightTheme,
        home: BaseViewerScreen(
          title: file.fileName,
          file: file,
          child: ListView(
            children: <Widget>[
              for (int i = 0; i < 60; i++)
                SizedBox(height: 40, child: Text('line $i')),
            ],
          ),
        ),
      ),
    );

Future<void> _scroll(WidgetTester tester, double dy) async {
  await tester.drag(find.byType(ListView), Offset(0, dy));
  await tester.pumpAndSettle();
}

void main() {
  group('Step 8 auto-hide chrome', () {
    testWidgets('A. both toolbars visible initially', (WidgetTester tester) async {
      await tester.pumpWidget(_harness(_file('txt')));
      await tester.pumpAndSettle();

      expect(find.byType(ViewerToolbar), findsOneWidget);
      expect(find.byType(ViewerBottomToolbar), findsOneWidget);
    });

    testWidgets('B. small downward scroll keeps both visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(_harness(_file('txt')));
      await tester.pumpAndSettle();

      // Below the AuraLayout.appBarHeight (56) threshold.
      await _scroll(tester, -20);

      expect(find.byType(ViewerToolbar), findsOneWidget);
      expect(find.byType(ViewerBottomToolbar), findsOneWidget);
    });

    testWidgets('C. downward scroll past the threshold hides both',
        (WidgetTester tester) async {
      await tester.pumpWidget(_harness(_file('txt')));
      await tester.pumpAndSettle();

      await _scroll(tester, -(AuraLayout.appBarHeight + 40));

      expect(find.byType(ViewerToolbar), findsNothing);
      expect(find.byType(ViewerBottomToolbar), findsNothing);
    });

    testWidgets('D. upward scroll restores both', (WidgetTester tester) async {
      await tester.pumpWidget(_harness(_file('txt')));
      await tester.pumpAndSettle();

      await _scroll(tester, -(AuraLayout.appBarHeight + 40));
      expect(find.byType(ViewerToolbar), findsNothing);

      await _scroll(tester, 30);

      expect(find.byType(ViewerToolbar), findsOneWidget);
      expect(find.byType(ViewerBottomToolbar), findsOneWidget);
    });

    testWidgets('E. image format never auto-hides', (WidgetTester tester) async {
      await tester.pumpWidget(_harness(_file('png')));
      await tester.pumpAndSettle();

      await _scroll(tester, -(AuraLayout.appBarHeight + 200));

      expect(find.byType(ViewerToolbar), findsOneWidget);
      expect(find.byType(ViewerBottomToolbar), findsOneWidget);
    });

    testWidgets('E. pdf format never auto-hides', (WidgetTester tester) async {
      await tester.pumpWidget(_harness(_file('pdf')));
      await tester.pumpAndSettle();

      await _scroll(tester, -(AuraLayout.appBarHeight + 200));

      expect(find.byType(ViewerToolbar), findsOneWidget);
      expect(find.byType(ViewerBottomToolbar), findsOneWidget);
    });

    testWidgets('docx inherits the text behaviour', (WidgetTester tester) async {
      await tester.pumpWidget(_harness(_file('docx')));
      await tester.pumpAndSettle();

      await _scroll(tester, -(AuraLayout.appBarHeight + 40));

      expect(find.byType(ViewerToolbar), findsNothing);
      expect(find.byType(ViewerBottomToolbar), findsNothing);
    });
  });
}
