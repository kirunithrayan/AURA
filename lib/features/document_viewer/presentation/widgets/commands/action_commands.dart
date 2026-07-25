import 'package:flutter/material.dart';
import 'viewer_command.dart';
import '../../viewmodels/document_viewer_viewmodel.dart';
import '../../../domain/services/document_share_service.dart';

class ShareCommand implements ViewerCommand {
  final DocumentShareService shareService;
  
  ShareCommand(this.shareService);

  @override
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]) async {
    final file = notifier.state.value?.file;
    if (file != null) {
      await shareService.shareDocument(file);
    }
  }
}

class OpenExternallyCommand implements ViewerCommand {
  final DocumentShareService shareService;
  
  OpenExternallyCommand(this.shareService);

  @override
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]) async {
    final file = notifier.state.value?.file;
    if (file != null) {
      await shareService.openExternally(file);
    }
  }
}

class CopyDocumentPathCommand implements ViewerCommand {
  final DocumentShareService shareService;
  
  CopyDocumentPathCommand(this.shareService);

  @override
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]) async {
    final file = notifier.state.value?.file;
    if (file != null) {
      await shareService.copyDocumentPath(file);
    }
  }
}
