import 'package:equatable/equatable.dart';
import 'node_type.dart';

/// Represents a node within the Knowledge Graph.
/// A node can either be an abstract concept or a physical document.
class KnowledgeNode extends Equatable {

  const KnowledgeNode({
    required this.id,
    required this.label,
    required this.type,
    required this.workspaceId,
    this.documentId,
    this.confidence = 1.0,
    this.frequency = 1,
    required this.createdAt,
  });
  final String id;
  final String label;
  final NodeType type;
  final String workspaceId;
  final String? documentId;
  final double confidence;
  final int frequency;
  final int createdAt;

  KnowledgeNode copyWith({
    String? id,
    String? label,
    NodeType? type,
    String? workspaceId,
    String? documentId,
    double? confidence,
    int? frequency,
    int? createdAt,
  }) => KnowledgeNode(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      workspaceId: workspaceId ?? this.workspaceId,
      documentId: documentId ?? this.documentId,
      confidence: confidence ?? this.confidence,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
    );

  @override
  List<Object?> get props => [
        id,
        label,
        type,
        workspaceId,
        documentId,
        confidence,
        frequency,
        createdAt,
      ];
}
