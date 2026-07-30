import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/document_metadata/data/cache/metadata_cache.dart';
import 'package:aura/features/document_metadata/domain/entities/document_metadata.dart';

void main() {
  group('MetadataCache', () {
    late MetadataCache cache;
    const testDoc = DocumentMetadata(
      id: '1',
      workspaceId: 'w1',
      fileName: 'test.pdf',
      filePath: '/path/test.pdf',
      createdAt: 1000,
      modifiedAt: 1000,
      importedAt: 1000,
    );

    setUp(() {
      cache = MetadataCache();
    });

    test('should store and retrieve metadata', () {
      cache.put(testDoc.id, testDoc);
      final retrieved = cache.get(testDoc.id);
      expect(retrieved, equals(testDoc));
    });

    test('should return null for non-existent id', () {
      final retrieved = cache.get('non-existent');
      expect(retrieved, isNull);
    });

    test('should remove metadata', () {
      cache.put(testDoc.id, testDoc);
      cache.remove(testDoc.id);
      final retrieved = cache.get(testDoc.id);
      expect(retrieved, isNull);
    });

    test('should clear all metadata', () {
      cache.put(testDoc.id, testDoc);
      cache.put('2', testDoc.copyWith(id: '2'));
      cache.clear();
      expect(cache.get(testDoc.id), isNull);
      expect(cache.get('2'), isNull);
    });
  });
}
