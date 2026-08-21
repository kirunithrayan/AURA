// Coverage for DocumentPrintServiceImpl.printDocument's own routing logic:
// missing-file handling and unsupported-format detection, both of which are
// rejected before the `printing` plugin's platform channel is ever reached.
//
// PLATFORM-ONLY: the actual native print dialog (Android PrintManager /
// PrintFileProvider) that Printing.layoutPdf opens for the supported formats
// is not simulated here — the plugin's channel ('net.nfet.printing') is
// bidirectional (the native side calls back into Dart for page bytes via
// onLayout), which is exactly the platform-only surface the task asks not to
// fake. That path is verified on the Realme device (Phase 8), not here.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:aura/features/document_viewer/data/services/document_print_service_impl.dart';
import 'package:aura/features/document_viewer/domain/services/document_print_service.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';

WorkspaceFile _file(String path, {String fileName = 'doc', String? extension}) =>
    WorkspaceFile(
      id: 'f1',
      workspaceId: 'ws1',
      fileName: fileName,
      filePath: path,
      extension: extension,
      createdAt: 0,
      modifiedAt: 0,
      importedAt: 0,
    );

void main() {
  group('DocumentPrintServiceImpl.printDocument', () {
    late Directory sourceDir;

    setUp(() async {
      sourceDir = await Directory.systemTemp.createTemp('aura_print_src_');
    });

    tearDown(() async {
      if (await sourceDir.exists()) await sourceDir.delete(recursive: true);
    });

    test('a missing source file is rejected before any print routing', () async {
      final file = _file(p.join(sourceDir.path, 'gone.pdf'), extension: 'pdf');

      await expectLater(
        DocumentPrintServiceImpl().printDocument(file),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('an unrecognized extension reports unsupported rather than faking support',
        () async {
      final source = File(p.join(sourceDir.path, 'archive.zip'))..writeAsBytesSync([1]);
      final file = _file(source.path, fileName: 'archive.zip', extension: 'zip');

      await expectLater(
        DocumentPrintServiceImpl().printDocument(file),
        throwsA(isA<UnsupportedPrintFormatException>()),
      );
    });

    test('docx/txt with no extracted text reports unsupported rather than '
        'printing nothing silently', () async {
      final source = File(p.join(sourceDir.path, 'empty.docx'))..writeAsBytesSync([1]);
      final file = _file(source.path, fileName: 'empty.docx', extension: 'docx');

      await expectLater(
        DocumentPrintServiceImpl().printDocument(file, textContent: null),
        throwsA(isA<UnsupportedPrintFormatException>()),
      );
    });

    test('UnsupportedPrintFormatException names the offending extension', () {
      const err = UnsupportedPrintFormatException('zip');
      expect(err.toString(), contains('.zip'));
    });
  });
}
