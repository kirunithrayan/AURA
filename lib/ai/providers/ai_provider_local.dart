import 'ai_provider.dart';
import '../models/document_chunk.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/vector_math.dart';

/// A local, non-generative implementation of the AIProvider.
/// Uses extractive techniques (TF-IDF, sentence extraction, cosine similarity).
class LocalRetrievalProvider implements AIProvider {
  
  @override
  Future<String> summarize(List<DocumentChunk> chunks) async {
    if (chunks.isEmpty) return "No content to summarize.";
    
    // Extractive Summary Pipeline:
    // 1. Sentence Extraction (from chunks)
    // 2. TF-IDF scoring of sentences
    // 3. Ranking
    // 4. Top N selection
    // 5. Restore original order
    
    // Stub implementation
    return chunks.take(AppConstants.summaryTopNSentences)
        .map((c) => c.text)
        .join(' ');
  }

  @override
  Future<List<String>> generateTags(List<DocumentChunk> chunks) async {
    // Uses TF-IDF on chunk terms to find highest-weighted keywords
    // Stub implementation
    return ['document', 'analysis', 'tags'];
  }

  @override
  Future<DocumentComparison> compareDocuments(
    List<DocumentChunk> chunksA,
    List<DocumentChunk> chunksB,
  ) async {
    // Averages chunk embeddings to get a document embedding, then cosine similarity.
    // Extracts TF-IDF topics for both sets to find overlap/unique.
    
    // Stub implementation
    return const DocumentComparison(
      similarityScore: 0.85,
      sharedTopics: ['topic1', 'topic2'],
      uniqueToA: ['topicA'],
      uniqueToB: ['topicB'],
      sharedKeywords: ['keyword1'],
    );
  }

  @override
  Future<List<DuplicateResult>> detectDuplicates(
    String fileId,
    List<double> embedding,
  ) async {
    // Scans database embeddings against provided embedding looking for > 0.85 match
    // Stub implementation
    return [];
  }
}
