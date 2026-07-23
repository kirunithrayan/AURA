import 'document_chunk.dart';

/// Represents a result from semantic or hybrid retrieval.
class RetrievalResult {
  final DocumentChunk chunk;
  final double similarityScore;
  final String sourceFileId;

  const RetrievalResult({
    required this.chunk,
    required this.similarityScore,
    required this.sourceFileId,
  });
}
