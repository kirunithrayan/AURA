import '../../domain/services/context_builder_service.dart';
import '../../domain/entities/context_chunk.dart';
import '../../../../search/domain/entities/search_result.dart';
import '../../../embeddings/domain/repositories/embedding_repository.dart';

class ContextBuilderServiceImpl implements ContextBuilderService {

  ContextBuilderServiceImpl(this._embeddingRepository);
  final EmbeddingRepository _embeddingRepository;

  @override
  Future<List<ContextChunk>> buildContext(List<SearchResult> results, {int maxLength = 3000}) async {
    final Map<String, ContextChunk> deduplicatedChunks = {};
    
    // Sort results by score descending
    final sortedResults = List<SearchResult>.from(results)
      ..sort((a, b) => b.score.compareTo(a.score));

    int currentLength = 0;

    for (final result in sortedResults) {
      if (currentLength >= maxLength) break;
      if (result.chunkIndex == null) continue;

      final documentId = result.metadata.id;
      final workspaceId = result.metadata.workspaceId;
      final fileName = result.metadata.fileName;

      // 1. Fetch all chunks for the document to get neighbors
      final docChunks = await _embeddingRepository.getDocumentEmbeddings(documentId);
      if (docChunks.isEmpty) continue;

      // Sort by index just in case
      docChunks.sort((a, b) => a.chunkIndex.compareTo(b.chunkIndex));
      
      final bestIdx = docChunks.indexWhere((c) => c.chunkIndex == result.chunkIndex);
      if (bestIdx == -1) continue;

      // 2. Include neighbors (1 before, 1 after)
      final List<String> snippetsToMerge = [];
      int startIndex = result.chunkIndex!;

      if (bestIdx > 0 && docChunks[bestIdx - 1].chunkIndex == result.chunkIndex! - 1) {
        snippetsToMerge.add(docChunks[bestIdx - 1].textSnippet);
        startIndex = docChunks[bestIdx - 1].chunkIndex; // Adjust start index for citation
      }

      snippetsToMerge.add(docChunks[bestIdx].textSnippet);

      if (bestIdx < docChunks.length - 1 && docChunks[bestIdx + 1].chunkIndex == result.chunkIndex! + 1) {
        snippetsToMerge.add(docChunks[bestIdx + 1].textSnippet);
      }

      final mergedSnippet = snippetsToMerge.join(' ... ');
      final chunkKey = '${documentId}_$startIndex';

      // 3. Deduplicate
      if (!deduplicatedChunks.containsKey(chunkKey)) {
        // Approximate token length (very naive: 4 chars ~ 1 token)
        final approxTokens = mergedSnippet.length ~/ 4;
        
        if (currentLength + approxTokens <= maxLength || deduplicatedChunks.isEmpty) {
          deduplicatedChunks[chunkKey] = ContextChunk(
            documentId: documentId,
            workspaceId: workspaceId,
            fileName: fileName,
            chunkIndex: startIndex, // Use the start index of the merged block
            textSnippet: mergedSnippet,
            similarityScore: result.score,
          );
          currentLength += approxTokens;
        }
      }
    }

    // Return the built context chunks (already ranked by how we sorted the results)
    return deduplicatedChunks.values.toList();
  }
}
