import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../../../core/constants/db_constants.dart';
import '../../../../../core/database/database_helper.dart';
import '../../domain/entities/knowledge_edge.dart';
import '../../domain/entities/knowledge_node.dart';
import '../../domain/entities/node_type.dart';
import '../../domain/entities/relationship_type.dart';
import '../../domain/repositories/knowledge_graph_repository.dart';

class KnowledgeGraphRepositoryImpl implements KnowledgeGraphRepository {

  KnowledgeGraphRepositoryImpl(this._dbHelper);
  final DatabaseHelper _dbHelper;

  @override
  Future<void> saveNode(KnowledgeNode node) async {
    final db = await _dbHelper.database;
    await db.insert(
      DbConstants.knowledgeNodesTable,
      _nodeToMap(node),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveNodes(List<KnowledgeNode> nodes) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final node in nodes) {
      batch.insert(
        DbConstants.knowledgeNodesTable,
        _nodeToMap(node),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> saveEdge(KnowledgeEdge edge) async {
    final db = await _dbHelper.database;
    await db.insert(
      DbConstants.knowledgeEdgesTable,
      _edgeToMap(edge),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveEdges(List<KnowledgeEdge> edges) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final edge in edges) {
      batch.insert(
        DbConstants.knowledgeEdgesTable,
        _edgeToMap(edge),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<KnowledgeNode?> getNode(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DbConstants.knowledgeNodesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToNode(maps.first);
    }
    return null;
  }

  @override
  Future<List<KnowledgeNode>> getNodesForWorkspace(String workspaceId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DbConstants.knowledgeNodesTable,
      where: 'workspace_id = ?',
      whereArgs: [workspaceId],
    );

    return maps.map(_mapToNode).toList();
  }

  @override
  Future<List<KnowledgeEdge>> getEdgesForWorkspace(String workspaceId) async {
    final db = await _dbHelper.database;
    // We join with the nodes table to check if either source or target belongs to the workspace.
    // In practice, both should belong to the same workspace.
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.*
      FROM ${DbConstants.knowledgeEdgesTable} e
      INNER JOIN ${DbConstants.knowledgeNodesTable} n ON e.source_id = n.id
      WHERE n.workspace_id = ?
    ''', [workspaceId]);

    return maps.map(_mapToEdge).toList();
  }

  @override
  Future<List<KnowledgeEdge>> getEdgesForNode(String nodeId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DbConstants.knowledgeEdgesTable,
      where: 'source_id = ? OR target_id = ?',
      whereArgs: [nodeId, nodeId],
    );

    return maps.map(_mapToEdge).toList();
  }

  @override
  Future<void> deleteNode(String id) async {
    final db = await _dbHelper.database;
    // Cascade delete on foreign keys will handle the edges.
    await db.delete(
      DbConstants.knowledgeNodesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> clearWorkspaceGraph(String workspaceId) async {
    final db = await _dbHelper.database;
    // Deleting nodes will cascade to edges
    await db.delete(
      DbConstants.knowledgeNodesTable,
      where: 'workspace_id = ?',
      whereArgs: [workspaceId],
    );
  }

  Map<String, dynamic> _nodeToMap(KnowledgeNode node) => {
      'id': node.id,
      'label': node.label,
      'type': node.type.name,
      'workspace_id': node.workspaceId,
      'document_id': node.documentId,
      'confidence': node.confidence,
      'frequency': node.frequency,
      'created_at': node.createdAt,
    };

  KnowledgeNode _mapToNode(Map<String, dynamic> map) => KnowledgeNode(
      id: map['id'] as String,
      label: map['label'] as String,
      type: NodeType.values.firstWhere((e) => e.name == map['type']),
      workspaceId: map['workspace_id'] as String,
      documentId: map['document_id'] as String?,
      confidence: map['confidence'] as double,
      frequency: map['frequency'] as int,
      createdAt: map['created_at'] as int,
    );

  Map<String, dynamic> _edgeToMap(KnowledgeEdge edge) => {
      'id': edge.id,
      'source_id': edge.sourceId,
      'target_id': edge.targetId,
      'relationship_type': edge.relationshipType.name,
      'weight': edge.weight,
      'created_at': edge.createdAt,
    };

  KnowledgeEdge _mapToEdge(Map<String, dynamic> map) => KnowledgeEdge(
      id: map['id'] as String,
      sourceId: map['source_id'] as String,
      targetId: map['target_id'] as String,
      relationshipType: RelationshipType.values.firstWhere((e) => e.name == map['relationship_type']),
      weight: map['weight'] as double,
      createdAt: map['created_at'] as int,
    );
}
