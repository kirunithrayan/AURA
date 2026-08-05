import '../../domain/services/context_builder_service.dart';
import '../../domain/entities/context_chunk.dart';
import '../../../../search/domain/entities/search_result.dart';

/// Builds RAG context from keyword search results.
///
/// The alternative implementation, [ContextBuilderServiceImpl], reads chunk
/// text out of the embeddings store. That store is never populated — on-device
/// embeddings are not implemented — so it returns an empty context for every
/// query, which made the whole RAG pipeline short-circuit before reaching the
/// AI provider. This implementation uses the snippet the keyword engine has
/// already extracted from the document itself, so no embeddings are involved.
///
/// ## Scores are relative, not cosine
///
/// Keyword scores are unbounded: [DefaultMatchingStrategy] adds 10.0 per exact
/// match and multiplies by 3.0 for a title hit, so a single document can score
/// 30+ while another scores 1.5. Those numbers cannot be compared against the
/// 0..1 `similarityThreshold` the RAG service filters on.
///
/// Each score is therefore divided by the top score in the result set, giving
/// a rank-relative confidence where the best match is always 1.0. Two
/// consequences worth knowing:
///
///   * The best match always survives the threshold, so a query that found
///     something never falls back to "no relevant information".
///   * `similarityScore` means "how strong relative to the best hit", not
///     "cosine similarity". Citations surface it, so it is a relevance
///     ranking, not a semantic distance.
class KeywordContextBuilderService implements ContextBuilderService {
  const KeywordContextBuilderService();

  @override
  Future<List<ContextChunk>> buildContext(
    List<SearchResult> results, {
    int maxLength = 3000,
  }) async {
    if (results.isEmpty) return [];

    final ranked = List<SearchResult>.from(results)
      ..sort((a, b) => b.score.compareTo(a.score));

    // Guard against a zero or negative top score so normalisation cannot
    // divide by zero or flip signs.
    final topScore = ranked.first.score;
    final divisor = topScore > 0 ? topScore : 1.0;

    final chunks = <ContextChunk>[];
    final seenDocuments = <String>{};
    var usedTokens = 0;

    for (final result in ranked) {
      final snippet = result.snippet?.trim();
      if (snippet == null || snippet.isEmpty) continue;

      // One chunk per document: the engine already merged the best window.
      if (!seenDocuments.add(result.metadata.id)) continue;

      // Same 4-chars-per-token approximation the embeddings builder used.
      final approxTokens = snippet.length ~/ 4;
      final wouldOverflow = usedTokens + approxTokens > maxLength;

      // Always admit the top chunk, even if it alone exceeds the budget —
      // an empty context sends the pipeline to the fallback message.
      if (wouldOverflow && chunks.isNotEmpty) continue;

      chunks.add(ContextChunk(
        documentId: result.metadata.id,
        workspaceId: result.metadata.workspaceId,
        fileName: result.metadata.fileName,
        chunkIndex: result.chunkIndex ?? 0,
        textSnippet: snippet,
        similarityScore: (result.score / divisor).clamp(0.0, 1.0),
      ));

      usedTokens += approxTokens;
    }

    return chunks;
  }
}
