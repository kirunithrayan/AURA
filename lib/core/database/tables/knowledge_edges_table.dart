import '../../constants/db_constants.dart';

/// Table definition for knowledge graph relationships.
class KnowledgeEdgesTable {
  KnowledgeEdgesTable._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.knowledgeEdgesTable} (
      id TEXT PRIMARY KEY,
      source_id TEXT NOT NULL,
      target_id TEXT NOT NULL,
      relationship_type TEXT NOT NULL,
      weight REAL NOT NULL,
      created_at INTEGER NOT NULL,
      FOREIGN KEY (source_id) REFERENCES ${DbConstants.knowledgeNodesTable} (id) ON DELETE CASCADE,
      FOREIGN KEY (target_id) REFERENCES ${DbConstants.knowledgeNodesTable} (id) ON DELETE CASCADE
    )
  ''';
}
