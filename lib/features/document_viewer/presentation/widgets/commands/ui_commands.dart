import 'package:flutter/material.dart';
import 'viewer_command.dart';
import '../../viewmodels/document_viewer_viewmodel.dart';
import '../document_metadata_sheet.dart';
import '../viewer_settings_sheet.dart';
import '../../../../../core/di/riverpod_providers.dart';
import '../../domain/entities/viewer_type.dart';

class ViewMetadataCommand implements ViewerCommand {
  @override
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]) async {
    if (payload is BuildContext) {
      final state = notifier.state.valueOrNull;
      if (state == null) return;
      
      MetadataProvider? provider;
      switch (state.viewerType) {
        case ViewerType.pdf: provider = PdfMetadataProvider(); break;
        case ViewerType.image: provider = ImageMetadataProvider(); break;
        case ViewerType.text:
        case ViewerType.docx: provider = TextMetadataProvider(); break;
        default: break;
      }

      showModalBottomSheet(
        context: payload,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => DocumentMetadataSheet(
          state: state,
          provider: provider,
        ),
      );
    }
  }
}

class OpenTextSettingsCommand implements ViewerCommand {
  @override
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]) async {
    if (payload is BuildContext) {
      final state = notifier.state.valueOrNull;
      if (state == null) return;

      showModalBottomSheet(
        context: payload,
        backgroundColor: Colors.transparent,
        builder: (ctx) => ViewerSettingsSheet(
          fileId: state.file!.id,
          initialPrefs: state.readingPreferences,
        ),
      );
    }
  }
}
