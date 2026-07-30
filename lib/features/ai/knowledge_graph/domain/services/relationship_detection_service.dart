import 'package:uuid/uuid.dart';

import '../entities/knowledge_edge.dart';
import '../entities/knowledge_node.dart';
import '../entities/relationship_type.dart';

/// Detects relationships between knowledge nodes.
class RelationshipDetectionService {
  final _uuid = const Uuid();

  /// Creates edges between a document node and its extracted concept nodes.
  List<KnowledgeEdge> detectDocumentToConceptRelationships({
    required KnowledgeNode documentNode,
    required List<KnowledgeNode> conceptNodes,
  }) => conceptNodes.map((concept) => KnowledgeEdge(
        id: _uuid.v4(),
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
            newEdges.add(
              KnowledgeEdge(
                id: _uuid.v4(),
                sourceId: doc1.id,
                targetId: doc2.id,
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
