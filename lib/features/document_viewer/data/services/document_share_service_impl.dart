import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/services/document_share_service.dart';
import 'package:aura/core/utils/file_utils.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';

class DocumentShareServiceImpl implements DocumentShareService {
  @override
  Future<void> shareDocument(WorkspaceFile file) async {
    final source = File(file.filePath);
    if (!await source.exists()) {
      throw const FileSystemException('Cannot share: the document is no longer on disk.');
    }

    // share_plus always copies the given path into its own FileProvider-backed
    // cache folder and uses the copy's basename as the shared filename — but
    // AURA's on-disk filePath is an internal UUID, not the document's real
    // name. Stage a same-content copy under the correct display name first so
    // the recipient sees "Lecture Notes.pdf", not a UUID. This copy is
    // AURA-private (app cache dir) and is only this one document — nothing
    // else in the workspace/app is exposed.
    final stagingDir = Directory(p.join((await getTemporaryDirectory()).path, 'aura_share'));
    await stagingDir.create(recursive: true);
    final stagedPath = p.join(stagingDir.path, FileUtils.sanitizeFileName(file.fileName));
    final staged = await source.copy(stagedPath);

    try {
      final mimeType = FileUtils.getMimeType(file.extension ?? '');
      await Share.shareXFiles([XFile(staged.path, mimeType: mimeType)]);
    } finally {
      if (await staged.exists()) {
        await staged.delete();
      }
    }
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
