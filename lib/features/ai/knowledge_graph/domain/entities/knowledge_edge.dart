import 'package:equatable/equatable.dart';
import 'relationship_type.dart';

/// Represents a directed relationship between two KnowledgeNodes.
class KnowledgeEdge extends Equatable {

  const KnowledgeEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    required this.relationshipType,
    required this.weight,
    required this.createdAt,
  });
  final String id;
  final String sourceId;
  final String targetId;
  final RelationshipType relationshipType;
  final double weight;
  final int createdAt;

  @override
  List<Object?> get props => [
        id,
        sourceId,
        targetId,
        relationshipType,
        weight,
        createdAt,
      ];
}
