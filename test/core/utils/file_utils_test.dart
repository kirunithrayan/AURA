// Coverage for FileUtils.getMimeType, specifically the docx/doc split fixed
// for document sharing: docx was previously mapped to the legacy .doc MIME
// type (application/msword), which is not what a docx file actually is.

import 'package:flutter_test/flutter_test.dart';

import 'package:aura/core/utils/file_utils.dart';

void main() {
  group('FileUtils.getMimeType', () {
    test('pdf', () {
      expect(FileUtils.getMimeType('pdf'), 'application/pdf');
    });

    test('txt', () {
      expect(FileUtils.getMimeType('txt'), 'text/plain');
    });

    test('docx uses the OOXML MIME type, distinct from legacy doc', () {
      expect(
        FileUtils.getMimeType('docx'),
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
    });

    test('doc keeps the legacy MIME type', () {
      expect(FileUtils.getMimeType('doc'), 'application/msword');
    });

    test('docx and doc no longer collide', () {
      expect(FileUtils.getMimeType('docx'), isNot(FileUtils.getMimeType('doc')));
    });

    test('jpg and jpeg both map to image/jpeg', () {
      expect(FileUtils.getMimeType('jpg'), 'image/jpeg');
      expect(FileUtils.getMimeType('jpeg'), 'image/jpeg');
    });

    test('png', () {
      expect(FileUtils.getMimeType('png'), 'image/png');
    });

    test('is case-insensitive', () {
      expect(FileUtils.getMimeType('PDF'), 'application/pdf');
      expect(FileUtils.getMimeType('DOCX'), FileUtils.getMimeType('docx'));
    });

    test('unknown extension falls back to octet-stream', () {
      expect(FileUtils.getMimeType('xyz'), 'application/octet-stream');
    });
  });
}
