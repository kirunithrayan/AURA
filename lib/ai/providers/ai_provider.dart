import '../models/document_chunk.dart';

/// Abstract AI provider interface mapped directly to the four deep AI features.
/// Currently implemented by LocalRetrievalProvider (chunk-based).
/// Future: A LocalLLMProvider can implement the same interface.
abstract class AIProvider {
  /// Generate an extractive summary from document chunks.
  Future<String> summarize(List<DocumentChunk> chunks);

  /// Generate keyword tags from document chunks via TF-IDF.
  Future<List<String>> generateTags(List<DocumentChunk> chunks);

  /// Compare two sets of document chunks.
  /// Returns similarity score, common topics, unique topics, shared keywords.
  Future<DocumentComparison> compareDocuments(
    List<DocumentChunk> chunksA,
    List<DocumentChunk> chunksB,
  );

  /// Detect near-duplicates by embedding similarity.
  /// Returns list of file IDs with similarity scores above threshold.
  Future<List<DuplicateResult>> detectDuplicates(
    String fileId,
    List<double> embedding,
  );
}

/// DTO for document comparison results.
class DocumentComparison {
  final double similarityScore;
  final List<String> sharedTopics;
  final List<String> uniqueToA;
  final List<String> uniqueToB;
  final List<String> sharedKeywords;

  const DocumentComparison({
    required this.similarityScore,
    required this.sharedTopics,
    required this.uniqueToA,
    required this.uniqueToB,
    required this.sharedKeywords,
  });
}

/// DTO for duplicate detection results.
class DuplicateResult {
  final String fileId;
  final double similarityScore;

  const DuplicateResult({
    required this.fileId,
    required this.similarityScore,
  });
}
