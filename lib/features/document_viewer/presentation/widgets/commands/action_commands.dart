import 'viewer_command.dart';
import 'package:aura/features/document_viewer/presentation/viewmodels/document_viewer_viewmodel.dart';
import '../../../domain/services/document_share_service.dart';

class ShareCommand implements ViewerCommand {
  
  ShareCommand(this.shareService);
  final DocumentShareService shareService;

  @override
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]) async {
    final file = notifier.state.value?.file;
    if (file != null) {
      await shareService.shareDocument(file);
    }
  }
}

class OpenExternallyCommand implements ViewerCommand {
  
  OpenExternallyCommand(this.shareService);
  final DocumentShareService shareService;

  @override
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]) async {
    final file = notifier.state.value?.file;
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
    final file = notifier.state.value?.file;
    if (file != null) {
      await shareService.copyDocumentPath(file);
    }
  }
}
