
import '../../../../../core/text_engine/abstract_text_document_engine.dart';
import '../../../../workspace/domain/entities/workspace_file.dart';
import '../../../../workspace/domain/repositories/workspace_repository.dart';
import '../entities/knowledge_edge.dart';
import '../entities/knowledge_node.dart';
import '../entities/node_type.dart';
import '../repositories/knowledge_graph_repository.dart';
import 'concept_extraction_service.dart';
import 'relationship_detection_service.dart';

/// Orchestrates the construction and updating of the Knowledge Graph.
///
/// Document text comes from the shared [AbstractTextDocumentEngine], the same
/// parser the search index uses. It cannot be read off the `workspace_files`
/// row: that table stores metadata only (`file_name`, `file_path`, counts) and
/// has no column holding the document body.
class KnowledgeGraphBuilder {

  KnowledgeGraphBuilder(
    this._repository,
    this._conceptExtractionService,
    this._relationshipDetectionService,
    this._workspaceRepository,
    this._textEngine,
  );
  final KnowledgeGraphRepository _repository;
  final ConceptExtractionService _conceptExtractionService;
  final RelationshipDetectionService _relationshipDetectionService;
  final WorkspaceRepository _workspaceRepository;
  final AbstractTextDocumentEngine _textEngine;

  /// Incrementally rebuilds the graph for a workspace.
  ///
  /// Pass [modifiedDocumentIds] to process only those documents; omit it to
  /// process every document in the workspace. Document-to-document edges are
  /// always recomputed across the whole workspace afterwards, so an incremental
  /// run still links new documents to ones already stored.
  ///
  /// Throws if the workspace's file list cannot be read. A document whose text
  /// fails to parse is skipped rather than aborting the build.
  Future<void> buildGraph({
    required String workspaceId,
    List<String>? modifiedDocumentIds,
  }) async {
    final filesResult = await _workspaceRepository.getWorkspaceFiles(workspaceId);

    final List<WorkspaceFile> allFiles = filesResult.fold(
      (failure) => throw Exception(
        'Knowledge graph build failed to read workspace $workspaceId: $failure',
      ),
      (files) => files,
    );

    final List<WorkspaceFile> documents;
    if (modifiedDocumentIds != null && modifiedDocumentIds.isNotEmpty) {
      final wanted = modifiedDocumentIds.toSet();
      documents = allFiles.where((f) => wanted.contains(f.id)).toList();
    } else {
      documents = allFiles;
    }

    if (documents.isEmpty) return;

    final List<KnowledgeNode> newDocumentNodes = [];
    final List<KnowledgeNode> newConceptNodes = [];
    final List<KnowledgeEdge> newEdges = [];

    final int currentTime = DateTime.now().millisecondsSinceEpoch;

    // Process each document
    for (final file in documents) {
      // A single unreadable or unsupported file must not cost the whole graph.
      // BatchIndexingServiceImpl takes the same per-document stance.
      String content;
      try {
        final textDoc = await _textEngine.openDocument(file);
        content = textDoc.content;
      } catch (_) {
        continue;
      }

      // 1. Create document node
      final docNode = KnowledgeNode(
        id: file.id, // use file ID as node ID
        label: file.fileName,
        type: NodeType.document,
        workspaceId: workspaceId,
        documentId: file.id,
        createdAt: currentTime,
      );
      newDocumentNodes.add(docNode);

      // 2. Extract concepts
      final concepts = _conceptExtractionService.extractConcepts(content, workspaceId, file.id);
      newConceptNodes.addAll(concepts);

      // 3. Detect document-to-concept relationships
      final edges = _relationshipDetectionService.detectDocumentToConceptRelationships(
        documentNode: docNode,
        conceptNodes: concepts,
      );
      newEdges.addAll(edges);
    }

    if (newDocumentNodes.isEmpty) return;

    // 4. Normalization and duplicate-merging step for concepts.
    // Keyed the same way the concept id is derived, so the merge key and the
    // stored identity cannot disagree.
    final Map<String, KnowledgeNode> mergedConcepts = {};
    for (final concept in newConceptNodes) {
      final key = ConceptExtractionService.normalizeLabel(concept.label);
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

    // No edge remap is needed. Merging collapses concepts that share a
    // normalized label, and the concept id is derived from that same label, so
    // every concept folded into a merged node already carries the merged node's
    // id. The edges written above therefore point at the surviving node.

    // 5. Save nodes and edges
    await _repository.saveNodes(newDocumentNodes);
    await _repository.saveNodes(finalConceptNodes);
    await _repository.saveEdges(newEdges);

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
