// Coverage for DocumentShareServiceImpl.shareDocument.
//
// Background: the original implementation passed the AURA-owned file's raw
// internal path (a UUID, not the document's real name) straight to
// share_plus, which uses the path's basename as the shared filename — so a
// recipient would see "a1b2c3d4....pdf" instead of "Lecture Notes.pdf". This
// suite proves the fix: the file staged for share_plus carries the correct
// display name, correct MIME type, and is cleaned up afterward, and that a
// missing source file is rejected before anything is staged or shared.
//
// The share_plus and path_provider platform channels are the actual OS
// integration boundary and are not re-implemented here (see PLATFORM-ONLY
// notes below and the Realme device verification for that layer). Both are
// given a minimal fake so this test exercises AURA's own staging logic
// against a real temp-directory file system, not a fake datasource.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:aura/features/document_viewer/data/services/document_share_service_impl.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';

const _shareChannel = MethodChannel('dev.fluttercommunity.plus/share');

/// Routes getTemporaryDirectory() to a real, test-owned temp directory
/// instead of hitting a platform channel.
class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.tempPath);
  final String tempPath;

  @override
  Future<String?> getTemporaryPath() async => tempPath;
}

WorkspaceFile _file(String path, {String fileName = 'Lecture Notes.pdf', String extension = 'pdf'}) =>
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
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory sourceDir;
  late Directory tempRoot;
  late List<MethodCall> shareCalls;

  setUp(() async {
    sourceDir = await Directory.systemTemp.createTemp('aura_share_src_');
    tempRoot = await Directory.systemTemp.createTemp('aura_share_tmp_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempRoot.path);

    shareCalls = <MethodCall>[];
    // PLATFORM-ONLY: this stands in for share_plus's native side. The real
    // Android chooser sheet, its FileProvider grant and the resulting
    // recipient app list are verified on-device (Phase 8), not simulated
    // here — share_plus's outgoing 'shareFiles' call is acknowledged so
    // AURA's own staging/cleanup logic (the part this suite owns) runs to
    // completion without a MissingPluginException.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_shareChannel, (call) async {
      shareCalls.add(call);
      return null;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_shareChannel, null);
    if (await sourceDir.exists()) await sourceDir.delete(recursive: true);
    if (await tempRoot.exists()) await tempRoot.delete(recursive: true);
  });

  group('DocumentShareServiceImpl.shareDocument', () {
    test('stages the file under its real display name, not the internal path',
        () async {
      final source = File(p.join(sourceDir.path, 'a1b2c3d4-uuid.pdf'));
      await source.writeAsBytes([1, 2, 3, 4]);
      final file = _file(source.path, fileName: 'Lecture Notes.pdf', extension: 'pdf');

      await DocumentShareServiceImpl().shareDocument(file);

      expect(shareCalls, hasLength(1));
      final paths = (shareCalls.single.arguments as Map)['paths'] as List;
      expect(paths, hasLength(1));
      expect(
        p.basename(paths.single as String),
        'Lecture Notes.pdf',
        reason: 'the recipient must see the document\'s real name, not the UUID path',
      );
    });

    test('passes the correct MIME type for each format', () async {
      final cases = <(String, String, String)>[
        ('report.pdf', 'pdf', 'application/pdf'),
        ('notes.txt', 'txt', 'text/plain'),
        (
          'contract.docx',
          'docx',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        ),
        ('photo.jpg', 'jpg', 'image/jpeg'),
      ];

      for (final (name, ext, expectedMime) in cases) {
        shareCalls.clear();
        final source = File(p.join(sourceDir.path, 'src_$name'));
        await source.writeAsBytes([0]);
        final file = _file(source.path, fileName: name, extension: ext);

        await DocumentShareServiceImpl().shareDocument(file);

        final mimeTypes = (shareCalls.single.arguments as Map)['mimeTypes'] as List;
        expect(mimeTypes.single, expectedMime, reason: 'wrong MIME type for .$ext');
      }
    });

    test('the staged copy preserves the exact source bytes before cleanup',
        () async {
      final bytes = List<int>.generate(256, (i) => i % 256);
      final source = File(p.join(sourceDir.path, 'uuid.bin'));
      await source.writeAsBytes(bytes);
      final file = _file(source.path, fileName: 'data.bin', extension: 'bin');

      List<int>? capturedBytes;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_shareChannel, (call) async {
        shareCalls.add(call);
        final paths = (call.arguments as Map)['paths'] as List;
        // Read before returning: shareDocument deletes its staged copy once
        // this handler's future completes, so fidelity must be checked here.
        capturedBytes = await File(paths.single as String).readAsBytes();
        return null;
      });

      await DocumentShareServiceImpl().shareDocument(file);

      expect(capturedBytes, bytes);
    });

    test('the staged temp copy is deleted after the share call completes',
        () async {
      final source = File(p.join(sourceDir.path, 'uuid.txt'));
      await source.writeAsString('hello');
      final file = _file(source.path, fileName: 'hello.txt', extension: 'txt');

      await DocumentShareServiceImpl().shareDocument(file);

      final stagedPath = (shareCalls.single.arguments as Map)['paths'] as List;
      expect(await File(stagedPath.single as String).exists(), isFalse,
          reason: 'the AURA-side staged copy must not be left behind');
    });

    test('a missing source file is rejected before anything is staged or shared',
        () async {
      final file = _file(p.join(sourceDir.path, 'does-not-exist.pdf'));

      await expectLater(
        DocumentShareServiceImpl().shareDocument(file),
        throwsA(isA<FileSystemException>()),
      );

      expect(shareCalls, isEmpty,
          reason: 'the share channel must never be reached for a missing file');
    });

    test('only the requested document is exposed, nothing else in the staging dir',
        () async {
      final a = File(p.join(sourceDir.path, 'uuid-a.txt'))..writeAsStringSync('a');
      final b = File(p.join(sourceDir.path, 'uuid-b.txt'))..writeAsStringSync('b');
      await DocumentShareServiceImpl()
          .shareDocument(_file(a.path, fileName: 'DocA.txt', extension: 'txt'));

      final stagingDir = Directory(p.join(tempRoot.path, 'aura_share'));
      final staged = stagingDir.existsSync()
          ? stagingDir.listSync().map((e) => p.basename(e.path)).toList()
          : <String>[];
      expect(staged, isNot(contains('uuid-b.txt')));
      expect(staged, isNot(contains(p.basename(b.path))));
    });
  });
}
