import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:aura/features/ai/embeddings/domain/repositories/embedding_repository.dart';
import 'package:aura/features/ai/embeddings/domain/entities/indexed_document_chunk.dart';
import 'package:aura/features/ai/rag/data/services/context_builder_service_impl.dart';
import 'package:aura/features/search/domain/entities/search_result.dart';
import 'package:aura/features/document_metadata/domain/entities/document_metadata.dart';
import 'context_builder_service_test.mocks.dart';

@GenerateMocks([EmbeddingRepository])
void main() {
  group('ContextBuilderService', () {
    late MockEmbeddingRepository mockRepo;
    late ContextBuilderServiceImpl service;

    setUp(() {
      mockRepo = MockEmbeddingRepository();
      service = ContextBuilderServiceImpl(mockRepo);
    });

    test('should fetch and merge neighboring chunks for top result', () async {
      when(mockRepo.getDocumentEmbeddings('doc1')).thenAnswer((_) async => [
        const IndexedDocumentChunk(chunkId: 'c1', documentId: 'doc1', chunkIndex: 0, textSnippet: 'Line 1.', embedding: [], createdAt: 0),
        const IndexedDocumentChunk(chunkId: 'c2', documentId: 'doc1', chunkIndex: 1, textSnippet: 'Line 2.', embedding: [], createdAt: 0),
        const IndexedDocumentChunk(chunkId: 'c3', documentId: 'doc1', chunkIndex: 2, textSnippet: 'Line 3.', embedding: [], createdAt: 0),
      ]);

      const docMeta = DocumentMetadata(
        id: 'doc1',
        fileName: 'doc1.pdf',
        fileExtension: 'pdf',
        filePath: '/some/path/doc1.pdf',
        importedAt: 0,
        createdAt: 0,
        modifiedAt: 0,
        workspaceId: 'ws1',
        isFavorite: false,
        isPinned: false,
      );

      final results = [
        const SearchResult(
          metadata: docMeta,
          score: 0.9,
          searchEngineType: 'semantic',
          chunkIndex: 1,
        )
      ];

      final chunks = await service.buildContext(results);

      expect(chunks.length, 1);
      // It should merge chunk 0, chunk 1, and chunk 2
      expect(chunks.first.textSnippet, 'Line 1. ... Line 2. ... Line 3.');
      expect(chunks.first.chunkIndex, 0); // Start index
    });
  });
}
