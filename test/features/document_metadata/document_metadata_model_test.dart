import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/document_metadata/data/models/document_metadata_model.dart';
import 'package:aura/features/document_metadata/domain/entities/document_metadata.dart';

void main() {
  group('DocumentMetadataModel', () {
    const testEntity = DocumentMetadata(
      id: 'doc-1',
      workspaceId: 'ws-1',
      fileName: 'report.pdf',
      fileExtension: 'pdf',
      mimeType: 'application/pdf',
      filePath: '/docs/report.pdf',
      fileSize: 1024,
      sha256: 'hash123',
      createdAt: 100000,
      modifiedAt: 200000,
      importedAt: 300000,
      lastOpenedAt: 400000,
      openCount: 5,
      lastViewedPage: 12,
      lastScrollPosition: 150.5,
      pageCount: 20,
      resolution: '1920x1080',
      wordCount: 500,
      paragraphCount: 10,
      characterCount: 3000,
      isFavorite: true,
      isPinned: false,
      isArchived: false,
    );

    test('should map from entity and back maintaining equality', () {
      final model = DocumentMetadataModel.fromEntity(testEntity);
      expect(model.id, equals(testEntity.id));
      expect(model.isFavorite, equals(testEntity.isFavorite));
    });

    test('should serialize to map and deserialize correctly', () {
      final model = DocumentMetadataModel.fromEntity(testEntity);
      final map = model.toMap();
      
      final restored = DocumentMetadataModel.fromMap(map);
      
      expect(restored.id, equals(model.id));
      expect(restored.workspaceId, equals(model.workspaceId));
      expect(restored.fileName, equals(model.fileName));
      expect(restored.lastScrollPosition, equals(model.lastScrollPosition));
      expect(restored.isFavorite, equals(model.isFavorite));
      expect(restored.isPinned, equals(model.isPinned));
    });

    test('should handle missing nullable fields in map gracefully', () {
      final map = {
        'id': 'doc-2',
        'workspace_id': 'ws-2',
        'file_name': 'minimal.txt',
        'file_path': '/docs/minimal.txt',
        'created_at': 100,
        'modified_at': 200,
        'imported_at': 300,
      };
      
      final restored = DocumentMetadataModel.fromMap(map);
      
      expect(restored.id, equals('doc-2'));
      expect(restored.fileExtension, isNull);
      expect(restored.openCount, equals(0));
      expect(restored.isFavorite, isFalse);
    });
  });
}
