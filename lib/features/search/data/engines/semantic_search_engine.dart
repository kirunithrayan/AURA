import '../../domain/engines/abstract_search_engine.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/entities/search_explanation.dart';
import '../../../ai/embeddings/domain/services/embedding_service.dart';
import '../../../ai/embeddings/domain/services/cosine_similarity_service.dart';
import '../../../ai/embeddings/domain/repositories/embedding_repository.dart';
import '../../../ai/embeddings/domain/entities/indexed_document_chunk.dart';
import '../cache/query_embedding_cache.dart';

class SemanticSearchEngine implements AbstractSearchEngine {

  SemanticSearchEngine(
    this._repository,
    this._embeddingService,
    this._embeddingRepository,
    this._similarityService,
    this._queryCache,
  );
  final SearchRepository _repository;
  final EmbeddingService _embeddingService;
  final EmbeddingRepository _embeddingRepository;
  final CosineSimilarityService _similarityService;
  final QueryEmbeddingCache _queryCache;

  // Configuration for semantic matches
  static const double _similarityThreshold = 0.55;

  @override
  String get engineType => 'semantic';

  @override
  Future<List<SearchResult>> search(SearchQuery query) async {
    final keyword = query.keyword.trim();
    if (keyword.isEmpty) return [];

    // 1. Get Query Embedding
    List<double>? queryVector = _queryCache.get(keyword);
    if (queryVector == null) {
      try {
        queryVector = await _embeddingService.generateEmbedding(keyword);
        _queryCache.put(keyword, queryVector);
      } catch (e) {
        // Fallback gracefully on embedding failure
        return [];
      }
    }

    // 2. Fetch candidates
    final candidates = await _repository.getCandidateMetadata(query);
    if (candidates.isEmpty) return [];

    final results = <SearchResult>[];

    // 3. Process each candidate
    for (final metadata in candidates) {
      final chunks = await _embeddingRepository.getDocumentEmbeddings(metadata.id);
      if (chunks.isEmpty) continue;

      // Calculate similarities
      double maxScore = -1.0;
      IndexedDocumentChunk? bestChunk;

      for (final chunk in chunks) {
        if (chunk.embedding.isEmpty) continue;
        final score = _similarityService.calculateSimilarity(queryVector, chunk.embedding);
        if (score > maxScore) {
          maxScore = score;
          bestChunk = chunk;
        }
      }

      if (maxScore >= _similarityThreshold && bestChunk != null) {
        // Merge adjacent chunks for context window
        final String mergedSnippet = _mergeAdjacentChunks(chunks, bestChunk);

        results.add(SearchResult(
          metadata: metadata,
          score: maxScore,
          snippet: mergedSnippet,
          explanation: SearchExplanation(
            semanticScore: maxScore,
            explanation: 'Strong semantic match found (Score: ${(maxScore * 100).toStringAsFixed(1)}%).',
          ),
          searchEngineType: engineType,
          chunkIndex: bestChunk.chunkIndex,
        ));
      }
    }

    // Results will be merged and ranked by Hybrid Ranking Engine later
    return results;
  }

  /// Merges the best chunk with its immediate previous and next adjacent chunks 
  /// (if present) to provide a richer context window snippet.
  String _mergeAdjacentChunks(List<IndexedDocumentChunk> allChunks, IndexedDocumentChunk bestChunk) {
    // Sort chunks by index just in case they are out of order
    final sortedChunks = List<IndexedDocumentChunk>.from(allChunks)
      ..sort((a, b) => a.chunkIndex.compareTo(b.chunkIndex));

    final bestIdx = sortedChunks.indexWhere((c) => c.chunkId == bestChunk.chunkId);
    if (bestIdx == -1) return bestChunk.textSnippet; // Fallback

    final List<String> snippets = [];

    // Previous chunk (if exists and has index = bestChunk.chunkIndex - 1)
    if (bestIdx > 0 && sortedChunks[bestIdx - 1].chunkIndex == bestChunk.chunkIndex - 1) {
      snippets.add(sortedChunks[bestIdx - 1].textSnippet);
    }

    // Current chunk
    snippets.add(bestChunk.textSnippet);

    // Next chunk (if exists and has index = bestChunk.chunkIndex + 1)
    if (bestIdx < sortedChunks.length - 1 && sortedChunks[bestIdx + 1].chunkIndex == bestChunk.chunkIndex + 1) {
      snippets.add(sortedChunks[bestIdx + 1].textSnippet);
    }

    // Merge with ellipses or spaces
    return snippets.join(' ... ');
  }
}
