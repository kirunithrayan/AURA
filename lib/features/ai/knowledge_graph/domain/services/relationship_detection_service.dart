import '../entities/knowledge_edge.dart';
import '../entities/knowledge_node.dart';
import '../entities/relationship_type.dart';

/// Detects relationships between knowledge nodes.
class RelationshipDetectionService {
  /// Stable identity for an edge, derived from the pair it connects.
  ///
  /// Same reason as the derived concept id: the graph is rebuilt on every
  /// import, and a random id would add a parallel duplicate edge each time
  /// instead of replacing the one already stored.
  static String edgeId(String kind, String sourceId, String targetId) =>
      '$kind:$sourceId:$targetId';

  /// Creates edges between a document node and its extracted concept nodes.
  List<KnowledgeEdge> detectDocumentToConceptRelationships({
    required KnowledgeNode documentNode,
    required List<KnowledgeNode> conceptNodes,
  }) => conceptNodes.map((concept) => KnowledgeEdge(
        id: edgeId('mentions', documentNode.id, concept.id),
        sourceId: documentNode.id,
        targetId: concept.id,
        relationshipType: RelationshipType.mentions,
        weight: concept.confidence, // Use concept confidence as weight
        createdAt: DateTime.now().millisecondsSinceEpoch,
      )).toList();

  /// Detects relationships between documents based on shared concepts.
  /// This is a simplified O(N^2) heuristic.
  List<KnowledgeEdge> detectDocumentToDocumentRelationships(List<KnowledgeNode> documentNodes, List<KnowledgeEdge> allEdges) {
    final List<KnowledgeEdge> newEdges = [];
    
    // Map document ID to set of concept IDs it mentions
    final Map<String, Set<String>> docToConcepts = {};
    for (final edge in allEdges) {
      if (edge.relationshipType == RelationshipType.mentions) {
        docToConcepts.putIfAbsent(edge.sourceId, () => {}).add(edge.targetId);
      }
    }

    for (int i = 0; i < documentNodes.length; i++) {
      for (int j = i + 1; j < documentNodes.length; j++) {
        final doc1 = documentNodes[i];
        final doc2 = documentNodes[j];
        
        final concepts1 = docToConcepts[doc1.id] ?? {};
        final concepts2 = docToConcepts[doc2.id] ?? {};
        
        final intersection = concepts1.intersection(concepts2);
        
        if (intersection.isNotEmpty) {
          // Weight based on Jaccard similarity of concepts
          final unionSize = concepts1.union(concepts2).length;
          final jaccard = unionSize > 0 ? intersection.length / unionSize : 0.0;
          
          if (jaccard > 0.1) { // Threshold for relatedness
            // Similarity is symmetric, and getNodesForWorkspace has no
            // ORDER BY, so the same pair can arrive in either order between
            // rebuilds. Order the pair before storing it so the row is the
            // same row every time rather than a mirrored duplicate.
            final first = doc1.id.compareTo(doc2.id) <= 0 ? doc1.id : doc2.id;
            final second = doc1.id.compareTo(doc2.id) <= 0 ? doc2.id : doc1.id;
            newEdges.add(
              KnowledgeEdge(
                id: edgeId('similar', first, second),
                sourceId: first,
                targetId: second,
                relationshipType: RelationshipType.semanticSimilarity,
                weight: jaccard,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              )
            );
          }
        }
      }
    }
    
    return newEdges;
  }
}
