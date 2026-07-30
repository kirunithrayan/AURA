import '../entities/knowledge_node.dart';
import '../entities/knowledge_edge.dart';

/// Repository interface for Knowledge Graph operations.
abstract class KnowledgeGraphRepository {
  /// Inserts or replaces a node in the graph.
  Future<void> saveNode(KnowledgeNode node);

  /// Inserts a list of nodes in batch.
  Future<void> saveNodes(List<KnowledgeNode> nodes);

  /// Inserts or replaces an edge in the graph.
  Future<void> saveEdge(KnowledgeEdge edge);

  /// Inserts a list of edges in batch.
  Future<void> saveEdges(List<KnowledgeEdge> edges);

  /// Retrieves a node by its ID.
  Future<KnowledgeNode?> getNode(String id);

  /// Retrieves all nodes for a specific workspace.
  Future<List<KnowledgeNode>> getNodesForWorkspace(String workspaceId);

  /// Retrieves all edges associated with a specific workspace.
  /// An edge is associated with a workspace if either its source or target node belongs to it.
  Future<List<KnowledgeEdge>> getEdgesForWorkspace(String workspaceId);

  /// Retrieves all edges connected to a specific node.
  Future<List<KnowledgeEdge>> getEdgesForNode(String nodeId);

  /// Deletes a node and its associated edges (should cascade).
  Future<void> deleteNode(String id);

  /// Clears all nodes and edges for a workspace.
  Future<void> clearWorkspaceGraph(String workspaceId);
}
