
import '../../../../../core/database/database_helper.dart';
import '../../../../../core/constants/db_constants.dart';
import '../entities/knowledge_edge.dart';
import '../entities/knowledge_node.dart';
import '../entities/node_type.dart';
import '../repositories/knowledge_graph_repository.dart';
import 'concept_extraction_service.dart';
import 'relationship_detection_service.dart';

/// Orchestrates the construction and updating of the Knowledge Graph.
class KnowledgeGraphBuilder { // Used for fetching workspace files text

  KnowledgeGraphBuilder(
    this._repository,
    this._conceptExtractionService,
    this._relationshipDetectionService,
    this._dbHelper,
  );
  final KnowledgeGraphRepository _repository;
  final ConceptExtractionService _conceptExtractionService;
  final RelationshipDetectionService _relationshipDetectionService;
  final DatabaseHelper _dbHelper;

  /// Incrementally rebuilds the graph for a workspace.
  /// If [modifiedDocumentIds] is empty, it can rebuild the whole graph or do nothing.
  Future<void> buildGraph({
    required String workspaceId,
    List<String>? modifiedDocumentIds,
  }) async {
    final db = await _dbHelper.database;
    
    // Fetch all documents or just modified ones.
    List<Map<String, dynamic>> documentsMaps;
    if (modifiedDocumentIds != null && modifiedDocumentIds.isNotEmpty) {
      final placeholders = List.filled(modifiedDocumentIds.length, '?').join(',');
      documentsMaps = await db.query(
        DbConstants.workspaceFilesTable,
        where: 'workspace_id = ? AND id IN ($placeholders)',
        whereArgs: [workspaceId, ...modifiedDocumentIds],
      );
    } else {
      // Fetch all if no specific documents provided
      documentsMaps = await db.query(
        DbConstants.workspaceFilesTable,
        where: 'workspace_id = ?',
        whereArgs: [workspaceId],
      );
    }

    if (documentsMaps.isEmpty) return;

    final List<KnowledgeNode> newDocumentNodes = [];
    final List<KnowledgeNode> newConceptNodes = [];
    final List<KnowledgeEdge> newEdges = [];

    final int currentTime = DateTime.now().millisecondsSinceEpoch;

    // Process each document
    for (final docMap in documentsMaps) {
      final String docId = docMap['id'] as String;
      final String title = docMap['name'] as String;
      final String content = docMap['content'] as String? ?? '';
      
      // 1. Create document node
      final docNode = KnowledgeNode(
        id: docId, // use file ID as node ID
        label: title,
        type: NodeType.document,
        workspaceId: workspaceId,
        documentId: docId,
        createdAt: currentTime,
      );
      newDocumentNodes.add(docNode);

      // 2. Extract concepts
      final concepts = _conceptExtractionService.extractConcepts(content, workspaceId, docId);
      newConceptNodes.addAll(concepts);
      
      // 3. Detect document-to-concept relationships
      final edges = _relationshipDetectionService.detectDocumentToConceptRelationships(
        documentNode: docNode,
        conceptNodes: concepts,
      );
      newEdges.addAll(edges);
    }

    // 4. Normalization and duplicate-merging step for concepts
    final Map<String, KnowledgeNode> mergedConcepts = {};
    for (final concept in newConceptNodes) {
      final key = concept.label.toLowerCase(); // simple normalization key
      if (mergedConcepts.containsKey(key)) {
        mergedConcepts[key] = mergedConcepts[key]!.copyWith(
          frequency: mergedConcepts[key]!.frequency + concept.frequency,
          confidence: (mergedConcepts[key]!.confidence + 0.1).clamp(0.0, 1.0),
        );
      } else {
        mergedConcepts[key] = concept;
      }
    }
    final List<KnowledgeNode> finalConceptNodes = mergedConcepts.values.toList();
    
    // Remap edges to point to merged concept IDs
    final List<KnowledgeEdge> finalEdges = newEdges.map((edge) {
      final originalTarget = newConceptNodes.firstWhere((c) => c.id == edge.targetId);
      final mergedTarget = mergedConcepts[originalTarget.label.toLowerCase()]!;
      return KnowledgeEdge(
        id: edge.id,
        sourceId: edge.sourceId,
        targetId: mergedTarget.id,
        relationshipType: edge.relationshipType,
        weight: edge.weight,
        createdAt: edge.createdAt,
      );
    }).toList();

    // 5. Save nodes and edges
    await _repository.saveNodes(newDocumentNodes);
    await _repository.saveNodes(finalConceptNodes);
    await _repository.saveEdges(finalEdges);
    
    // 6. Detect document-to-document relationships based on shared concepts
    // We fetch all document nodes and all mentions edges to do this globally for the workspace
    final allNodes = await _repository.getNodesForWorkspace(workspaceId);
    final allExistingEdges = await _repository.getEdgesForWorkspace(workspaceId);
    
    final allDocNodes = allNodes.where((n) => n.type == NodeType.document).toList();
    
    final docToDocEdges = _relationshipDetectionService.detectDocumentToDocumentRelationships(
      allDocNodes,
      allExistingEdges,
    );
    
    await _repository.saveEdges(docToDocEdges);
  }
}
