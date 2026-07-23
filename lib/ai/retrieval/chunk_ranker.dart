import '../models/retrieval_result.dart';
import '../../core/utils/vector_math.dart';

/// Ranks document chunks based on embedding similarity and optional metadata.
class ChunkRanker {
  ChunkRanker._();

  /// Ranks a list of candidate chunks against a query embedding.
  /// Returns the top [k] results sorted by highest similarity score.
  static List<RetrievalResult> rankBySimilarity(
    List<double> queryEmbedding,
    List<RetrievalResult> candidates, {
    int k = 10,
    double threshold = 0.3,
  }) {
    if (queryEmbedding.isEmpty || candidates.isEmpty) return [];

    final scoredCandidates = <RetrievalResult>[];

    for (final candidate in candidates) {
      if (candidate.chunk.embedding == null) continue;
      
      final score = VectorMath.cosineSimilarity(
        queryEmbedding,
        candidate.chunk.embedding!,
      );

      if (score >= threshold) {
        scoredCandidates.add(
          RetrievalResult(
            chunk: candidate.chunk,
            similarityScore: score,
            sourceFileId: candidate.sourceFileId,
          ),
        );
      }
    }

    // Sort descending by score
    scoredCandidates.sort((a, b) => b.similarityScore.compareTo(a.similarityScore));

    // Return top K
    return scoredCandidates.take(k).toList();
  }
}
