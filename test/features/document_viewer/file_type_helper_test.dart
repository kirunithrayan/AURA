import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/document_viewer/core/utils/file_type_helper.dart';
import 'package:aura/features/document_viewer/domain/entities/viewer_type.dart';

void main() {
  group('FileTypeHelper', () {
    test('should return ViewerType.pdf for pdf extension', () {
      expect(FileTypeHelper.getViewerType('pdf'), equals(ViewerType.pdf));
      expect(FileTypeHelper.getViewerType('PDF'), equals(ViewerType.pdf));
    });

    test('should return ViewerType.image for image extensions', () {
      expect(FileTypeHelper.getViewerType('jpg'), equals(ViewerType.image));
      expect(FileTypeHelper.getViewerType('jpeg'), equals(ViewerType.image));
      expect(FileTypeHelper.getViewerType('png'), equals(ViewerType.image));
      expect(FileTypeHelper.getViewerType('webp'), equals(ViewerType.image));
      expect(FileTypeHelper.getViewerType('JPG'), equals(ViewerType.image));
    });

    test('should return ViewerType.text for text extensions', () {
      expect(FileTypeHelper.getViewerType('txt'), equals(ViewerType.text));
      expect(FileTypeHelper.getViewerType('TXT'), equals(ViewerType.text));
    });

    test('should return ViewerType.docx for word extensions', () {
      expect(FileTypeHelper.getViewerType('docx'), equals(ViewerType.docx));
      expect(FileTypeHelper.getViewerType('doc'), equals(ViewerType.docx));
    });

    test('should return ViewerType.unsupported for unknown or empty extensions', () {
      expect(FileTypeHelper.getViewerType('xyz'), equals(ViewerType.unsupported));
      expect(FileTypeHelper.getViewerType(''), equals(ViewerType.unsupported));
      expect(FileTypeHelper.getViewerType(null), equals(ViewerType.unsupported));
    });
  });
}
