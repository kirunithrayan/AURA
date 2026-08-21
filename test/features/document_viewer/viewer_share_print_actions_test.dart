// Coverage that Share and Print are actually reachable in the reader UI, not
// just declared as capabilities:
//
// - the top ViewerToolbar exposes a "Share document" icon (existing action,
//   unchanged) when the share capability is present;
// - Print is NOT a fourth top-level app-bar action — it lives inside the
//   existing overflow menu (ViewerActionMenu), alongside Share/Open
//   Externally/Copy/Metadata;
// - capability gating hides Print entirely when the format doesn't support it;
// - tapping Print in the overflow dispatches through the action registry,
//   the same command-registry path every other reader action already uses.

import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/document_viewer/domain/entities/viewer_capability.dart';
import 'package:aura/features/document_viewer/presentation/viewmodels/document_viewer_viewmodel.dart';
import 'package:aura/features/document_viewer/presentation/widgets/commands/viewer_command.dart';
import 'package:aura/features/document_viewer/presentation/widgets/registries/viewer_action_registry.dart';
import 'package:aura/features/document_viewer/presentation/widgets/viewer_toolbar.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

WorkspaceFile _file() => const WorkspaceFile(
      id: 'f1',
      workspaceId: 'ws1',
      fileName: 'report.pdf',
      filePath: '/tmp/report.pdf',
      extension: 'pdf',
      createdAt: 0,
      modifiedAt: 0,
      importedAt: 0,
    );

class _FakeViewerViewModel extends DocumentViewerViewModel {
  _FakeViewerViewModel(this._state);
  final DocumentViewerViewModelState _state;

  @override
  Future<DocumentViewerViewModelState> build(String documentId) async => _state;
}

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
}) {
  final WorkspaceFile file = _file();
  final DocumentViewerViewModelState state = DocumentViewerViewModelState(file: file);
  return ProviderScope(
    overrides: <Override>[
      documentViewerViewModelProvider(file.id)
          .overrideWith(() => _FakeViewerViewModel(state)),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        appBar: ViewerToolbar(
          file: file,
          capabilities: capabilities,
          actionRegistry: registry,
        ),
      ),
    ),
  );
}

void main() {
  group('Share reachability (top-level toolbar action, unchanged)', () {
    testWidgets('Share icon is present when the share capability is enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(_harness(
        capabilities: <ViewerCapability>{ViewerCapability.share},
        registry: ViewerActionRegistry(),
      ));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Share document'), findsOneWidget);
    });

    testWidgets('Share icon is absent when the share capability is disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(_harness(
        capabilities: <ViewerCapability>{},
        registry: ViewerActionRegistry(),
      ));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Share document'), findsNothing);
    });

    testWidgets('tapping Share dispatches through the action registry',
        (WidgetTester tester) async {
      final registry = ViewerActionRegistry();
      final share = _RecordingCommand();
      registry.register(ViewerCapability.share, share);

      await tester.pumpWidget(_harness(
        capabilities: <ViewerCapability>{ViewerCapability.share},
        registry: registry,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Share document'));
      await tester.pumpAndSettle();

      expect(share.payloads, hasLength(1));
    });
  });

  group('Print reachability (overflow menu, no new top-level app-bar action)', () {
    testWidgets('the app bar exposes exactly the pre-existing 3 top-level '
        'action slots (share icon, metadata icon, overflow) — Print adds none',
        (WidgetTester tester) async {
      await tester.pumpWidget(_harness(
        capabilities: <ViewerCapability>{
          ViewerCapability.share,
          ViewerCapability.print,
          ViewerCapability.metadata,
        },
        registry: ViewerActionRegistry(),
      ));
      await tester.pumpAndSettle();

      final AppBar appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actions, hasLength(3),
          reason: 'Print must not add a 4th top-level app-bar widget');
      expect(find.byTooltip('Share document'), findsOneWidget);
      expect(find.byTooltip('View document metadata'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      // Print itself is not a standalone top-level icon.
      expect(find.byTooltip('Print document'), findsNothing);
    });

    testWidgets('Print appears in the overflow menu when the capability is enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(_harness(
        capabilities: <ViewerCapability>{ViewerCapability.print},
        registry: ViewerActionRegistry(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Print'), findsOneWidget);
    });

    testWidgets('Print is absent from the overflow menu when the format has no '
        'printable content path', (WidgetTester tester) async {
      await tester.pumpWidget(_harness(
        capabilities: <ViewerCapability>{ViewerCapability.share},
        registry: ViewerActionRegistry(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Print'), findsNothing);
    });

    testWidgets('tapping Print in the overflow dispatches through the action registry',
        (WidgetTester tester) async {
      final registry = ViewerActionRegistry();
      final print = _RecordingCommand();
      registry.register(ViewerCapability.print, print);

      await tester.pumpWidget(_harness(
        capabilities: <ViewerCapability>{ViewerCapability.print},
        registry: registry,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Print'));
      await tester.pumpAndSettle();

      expect(print.payloads, hasLength(1));
    });
  });
}
