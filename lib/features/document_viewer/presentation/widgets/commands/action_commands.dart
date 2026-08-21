import 'package:flutter/widgets.dart';

import 'viewer_command.dart';
import 'package:aura/features/document_viewer/presentation/viewmodels/document_viewer_viewmodel.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../domain/services/document_share_service.dart';
import '../../../domain/services/document_print_service.dart';

/// Both the top-level toolbar icon and the overflow menu invoke commands as
/// `command.execute(notifier, context)`, so [payload] is always the
/// [BuildContext] the action was triggered from — used here only to surface
/// an error snackbar, never retained past this call.
BuildContext? _contextOf(dynamic payload) => payload is BuildContext ? payload : null;

class ShareCommand implements ViewerCommand {

  ShareCommand(this.shareService);
  final DocumentShareService shareService;

  @override
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]) async {
    final file = notifier.currentState?.file;
    if (file == null) return;
    try {
      await shareService.shareDocument(file);
    } catch (e) {
      final context = _contextOf(payload);
      if (context != null && context.mounted) {
        context.showSnackBar('Could not share this document.', isError: true);
      }
    }
  }
}

class PrintCommand implements ViewerCommand {

  PrintCommand(this.printService);
  final DocumentPrintService printService;

  @override
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]) async {
    final state = notifier.currentState;
    final file = state?.file;
    if (file == null) return;
    try {
      await printService.printDocument(file, textContent: state?.textDocument?.content);
    } catch (e) {
      final context = _contextOf(payload);
      if (context != null && context.mounted) {
        context.showSnackBar(
          e is UnsupportedPrintFormatException
              ? e.toString()
              : 'Could not print this document.',
          isError: true,
        );
      }
    }
  }
}

class OpenExternallyCommand implements ViewerCommand {

  OpenExternallyCommand(this.shareService);
  final DocumentShareService shareService;

  @override
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]) async {
    final file = notifier.currentState?.file;
    if (file != null) {
      await shareService.openExternally(file);
    }
  }
}

class CopyDocumentPathCommand implements ViewerCommand {

  CopyDocumentPathCommand(this.shareService);
  final DocumentShareService shareService;

  @override
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]) async {
    final file = notifier.currentState?.file;
    if (file != null) {
      await shareService.copyDocumentPath(file);
    }
  }
}
