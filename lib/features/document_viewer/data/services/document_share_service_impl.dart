import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/services/document_share_service.dart';
import '../../../../workspace/domain/entities/workspace_file.dart';

class DocumentShareServiceImpl implements DocumentShareService {
  @override
  Future<void> shareDocument(WorkspaceFile file) async {
    final xFile = XFile(file.filePath);
    await Share.shareXFiles([xFile], text: 'Sharing ${file.fileName}');
  }

  @override
  Future<void> openExternally(WorkspaceFile file) async {
    final uri = Uri.file(file.filePath);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Cannot open file externally');
    }
  }

  @override
  Future<void> copyDocumentPath(WorkspaceFile file) async {
    await Clipboard.setData(ClipboardData(text: file.filePath));
  }
}
