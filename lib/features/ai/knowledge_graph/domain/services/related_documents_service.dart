import 'dart:math';

import '../../../../../core/constants/db_constants.dart';
import '../../../../../core/database/database_helper.dart';
import '../entities/relationship_type.dart';
import '../repositories/knowledge_graph_repository.dart';

/// Represents a related document with its computed hybrid score.
class RelatedDocumentResult {

  RelatedDocumentResult({
    required this.documentId,
    required this.title,
    required this.score,
  });
  final String documentId;
  final String title;
  final double score;
}

/// Service to find related documents using a hybrid score.
class RelatedDocumentsService {

  RelatedDocumentsService(this._graphRepository, this._dbHelper);
  final KnowledgeGraphRepository _graphRepository;
  final DatabaseHelper _dbHelper;

  /// Retrieves related documents for a given document, ordered by hybrid score.
  Future<List<RelatedDocumentResult>> getRelatedDocuments(String documentId, String workspaceId) async {
    final edges = await _graphRepository.getEdgesForNode(documentId);
    
    // Map of related document ID to its shared concepts / semantic similarity score
    final Map<String, double> relatedDocScores = {};

    for (final edge in edges) {
      if (edge.relationshipType == RelationshipType.semanticSimilarity) {
        final otherId = edge.sourceId == documentId ? edge.targetId : edge.sourceId;
        relatedDocScores[otherId] = edge.weight;
      }
    }

    if (relatedDocScores.isEmpty) {
      return [];
    }

    // Fetch recency for the related documents
    final db = await _dbHelper.database;
    final placeholders = List.filled(relatedDocScores.length, '?').join(',');
    final List<Map<String, dynamic>> docMaps = await db.query(
      DbConstants.workspaceFilesTable,
      where: 'workspace_id = ? AND id IN ($placeholders)',
      whereArgs: [workspaceId, ...relatedDocScores.keys],
    );

    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    final List<RelatedDocumentResult> results = [];

    for (final map in docMaps) {
      final id = map['id'] as String;
      final title = map['name'] as String;
      final updatedAt = map['updated_at'] as int? ?? currentTime;

      final baseScore = relatedDocScores[id] ?? 0.0;
      
      // Calculate recency penalty (e.g., decay over 30 days)
      final ageMs = currentTime - updatedAt;
      final ageDays = ageMs / (1000 * 60 * 60 * 24);
      final recencyScore = max(0.0, 1.0 - (ageDays / 30.0)); // 1.0 for new, 0.0 for > 30 days old

      // Hybrid score: 80% shared concepts/semantic, 20% recency
      final hybridScore = (baseScore * 0.8) + (recencyScore * 0.2);

      results.add(RelatedDocumentResult(
        documentId: id,
        title: title,
        score: hybridScore,
      ));
    }

    // Sort descending by score
    results.sort((a, b) => b.score.compareTo(a.score));

    return results;
  }
}
