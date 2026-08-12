import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/document_viewer/domain/entities/document_view_state.dart';
import 'package:aura/features/document_viewer/domain/entities/viewer_capability.dart';
import 'package:aura/features/document_viewer/presentation/viewmodels/document_viewer_viewmodel.dart';
import 'package:aura/features/document_viewer/presentation/widgets/commands/viewer_command.dart';
import 'package:aura/features/document_viewer/presentation/widgets/registries/viewer_action_registry.dart';
import 'package:aura/features/document_viewer/presentation/widgets/viewer_bottom_toolbar.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bottom toolbar accessibility coverage.
///
/// Proves the Option-1 tooltip fix: every raw IconButton names its action,
/// while the pre-existing dispatch, disabled logic and capability gating are
/// left exactly as they were.
WorkspaceFile _file() => const WorkspaceFile(
      id: 'f1',
      workspaceId: 'ws1',
      fileName: 'notes.txt',
      filePath: '/tmp/notes.txt',
      extension: 'txt',
      createdAt: 0,
      modifiedAt: 0,
      importedAt: 0,
    );

/// Test-only notifier that yields a fixed viewer state, so no repository,
/// database, or file system is touched.
class _FakeViewerViewModel extends DocumentViewerViewModel {
  _FakeViewerViewModel(this._state);
  final DocumentViewerViewModelState _state;

  @override
  Future<DocumentViewerViewModelState> build(String documentId) async => _state;
}

/// Records each dispatched payload so callback wiring can be asserted.
class _RecordingCommand implements ViewerCommand {
  final List<dynamic> payloads = <dynamic>[];

  @override
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]) async {
    payloads.add(payload);
  }
}

Widget _harness({
  required Set<ViewerCapability> capabilities,
  required ViewerActionRegistry registry,
  int currentPage = 1,
  int pageCount = 10,
}) {
  final WorkspaceFile file = _file();
  final DocumentViewerViewModelState state = DocumentViewerViewModelState(
    file: file,
    viewState: DocumentViewState(currentPage: currentPage, pageCount: pageCount),
  );
  return ProviderScope(
    overrides: <Override>[
      documentViewerViewModelProvider(file.id)
          .overrideWith(() => _FakeViewerViewModel(state)),
    ],
    child: MaterialApp(
      // The toolbar resolves design tokens through the AuraTokens extension,
      // which only the production theme registers.
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: ViewerBottomToolbar(
          file: file,
          capabilities: capabilities,
          actionRegistry: registry,
        ),
      ),
    ),
  );
}

void main() {
  group('ViewerBottomToolbar accessibility', () {
    testWidgets('A. all seven action tooltips are present when every '
        'capability is enabled', (WidgetTester tester) async {
      final registry = ViewerActionRegistry();
      await tester.pumpWidget(_harness(
        capabilities: <ViewerCapability>{
          ViewerCapability.pageNavigation,
          ViewerCapability.zoom,
          ViewerCapability.rotate,
          ViewerCapability.textSettings,
        },
        registry: registry,
      ));
      await tester.pumpAndSettle();

      for (final String tip in <String>[
        'Previous page',
        'Next page',
        'Zoom out',
        'Zoom in',
        'Rotate left',
        'Rotate right',
        'Text settings',
      ]) {
        expect(find.byTooltip(tip), findsOneWidget, reason: 'missing tooltip: $tip');
      }
    });

    testWidgets('B. prev disabled on the first page, next enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(_harness(
        capabilities: <ViewerCapability>{ViewerCapability.pageNavigation},
        registry: ViewerActionRegistry(),
        currentPage: 1,
        pageCount: 10,
      ));
      await tester.pumpAndSettle();

      final IconButton prev = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_upward));
      final IconButton next = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_downward));
      expect(prev.onPressed, isNull, reason: 'prev must be disabled on page 1');
      expect(next.onPressed, isNotNull, reason: 'next must be enabled mid-doc');
    });

    testWidgets('B2. next disabled on the last page, prev enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(_harness(
        capabilities: <ViewerCapability>{ViewerCapability.pageNavigation},
        registry: ViewerActionRegistry(),
        currentPage: 10,
        pageCount: 10,
      ));
      await tester.pumpAndSettle();

      final IconButton prev = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_upward));
      final IconButton next = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_downward));
      expect(prev.onPressed, isNotNull, reason: 'prev must be enabled on page 10');
      expect(next.onPressed, isNull, reason: 'next must be disabled on last page');
    });

    testWidgets('C. capability gating: only enabled capabilities render controls',
        (WidgetTester tester) async {
      await tester.pumpWidget(_harness(
        capabilities: <ViewerCapability>{ViewerCapability.zoom},
        registry: ViewerActionRegistry(),
      ));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Zoom out'), findsOneWidget);
      expect(find.byTooltip('Zoom in'), findsOneWidget);
      // Page-nav, rotate and text-settings capabilities are absent.
      expect(find.byTooltip('Previous page'), findsNothing);
      expect(find.byTooltip('Next page'), findsNothing);
      expect(find.byTooltip('Rotate left'), findsNothing);
      expect(find.byTooltip('Rotate right'), findsNothing);
      expect(find.byTooltip('Text settings'), findsNothing);
    });

    testWidgets('D. tapping an action still dispatches through the registry',
        (WidgetTester tester) async {
      final registry = ViewerActionRegistry();
      final zoom = _RecordingCommand();
      registry.register(ViewerCapability.zoom, zoom);

      await tester.pumpWidget(_harness(
        capabilities: <ViewerCapability>{ViewerCapability.zoom},
        registry: registry,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Zoom in'));
      await tester.tap(find.byTooltip('Zoom out'));
      await tester.pumpAndSettle();

      expect(zoom.payloads, <String>['in', 'out']);
    });

    testWidgets('E. page counter exposes a descriptive "Page X of Y" label',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_harness(
        capabilities: <ViewerCapability>{ViewerCapability.pageNavigation},
        registry: ViewerActionRegistry(),
        currentPage: 3,
        pageCount: 10,
      ));
      await tester.pumpAndSettle();

      // The raw "3 / 10" glyphs are excluded from semantics; the descriptive
      // label replaces them for screen readers.
      expect(find.bySemanticsLabel('Page 3 of 10'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('E2. page counter carries the button role',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_harness(
        capabilities: <ViewerCapability>{ViewerCapability.pageNavigation},
        registry: ViewerActionRegistry(),
        currentPage: 3,
        pageCount: 10,
      ));
      await tester.pumpAndSettle();

      final node = tester.getSemantics(find.bySemanticsLabel('Page 3 of 10'));
      expect(node.flagsCollection.isButton, isTrue,
          reason: 'page counter must announce as a button');

      handle.dispose();
    });

    testWidgets('E3. tapping the page counter opens the jump-to-page dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(_harness(
        capabilities: <ViewerCapability>{ViewerCapability.pageNavigation},
        registry: ViewerActionRegistry(),
        currentPage: 3,
        pageCount: 10,
      ));
      await tester.pumpAndSettle();

      // Tap the visible page-counter text; behavior must be preserved.
      await tester.tap(find.text('3 / 10'));
      await tester.pumpAndSettle();

      expect(find.text('Jump to Page'), findsOneWidget);
    });
  });
}
