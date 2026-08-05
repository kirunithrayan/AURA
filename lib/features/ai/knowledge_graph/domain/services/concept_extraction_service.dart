import '../entities/knowledge_node.dart';
import '../entities/node_type.dart';

/// Extracts concept nodes from document text using heuristics.
class ConceptExtractionService {
  /// Extracts concept nodes from a document's text using simple heuristics.
  List<KnowledgeNode> extractConcepts(String text, String workspaceId, String documentId) {
    final Map<String, KnowledgeNode> conceptMap = {};
    
    // Heuristic 1: Extract capitalized phrases (1-3 words).
    // E.g., "Machine Learning", "Clean Architecture"
    final RegExp capitalizedPhraseRegExp = RegExp(r'\b[A-Z][a-z]+(?:\s+[A-Z][a-z]+){0,2}\b');
    final matches = capitalizedPhraseRegExp.allMatches(text);

    for (final match in matches) {
      final phrase = match.group(0);
      if (phrase != null) {
        final normalized = _normalize(phrase);
        // Ignore too short phrases or common stop words (simplified)
        if (normalized.length > 3 && !_isStopWord(normalized)) {
           if (conceptMap.containsKey(normalized)) {
             conceptMap[normalized] = conceptMap[normalized]!.copyWith(
               frequency: conceptMap[normalized]!.frequency + 1,
               confidence: (conceptMap[normalized]!.confidence + 0.1).clamp(0.0, 1.0),
             );
           } else {
             conceptMap[normalized] = KnowledgeNode(
               id: conceptId(workspaceId, normalized),
               label: phrase, // keep original casing for label
               type: NodeType.concept,
               workspaceId: workspaceId,
               documentId: documentId,
               confidence: 0.5, // Base confidence for heuristic extraction
               frequency: 1,
               createdAt: DateTime.now().millisecondsSinceEpoch,
             );
           }
        }
      }
    }
    
    return conceptMap.values.toList();
  }
  
  /// Collapses a raw phrase to its comparison form: lowercased, trimmed, and
  /// with runs of whitespace (including newlines, which the phrase regex can
  /// match between words) reduced to a single space.
  ///
  /// [KnowledgeGraphBuilder] merges concepts across documents with this same
  /// key, so a concept must normalize identically wherever it is seen.
  static String normalizeLabel(String input) =>
      input.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Stable identity for a concept, derived from its workspace and normalized
  /// label rather than a random UUID.
  ///
  /// The graph is rebuilt on every import and on first open of an empty graph.
  /// With a random id each rebuild would insert a second row for a concept it
  /// had already stored; a derived id makes `ConflictAlgorithm.replace` collapse
  /// the repeat onto the existing node, so rebuilding is idempotent.
  static String conceptId(String workspaceId, String normalizedLabel) =>
      'concept:$workspaceId:$normalizedLabel';

  String _normalize(String input) => normalizeLabel(input);

  bool _isStopWord(String word) {
    const stopWords = {'the', 'and', 'this', 'that', 'with', 'from', 'your', 'what', 'when', 'where', 'how', 'why'};
    return stopWords.contains(word);
  }
}
