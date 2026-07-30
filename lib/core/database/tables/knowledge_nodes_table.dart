import '../../constants/db_constants.dart';

/// Table definition for knowledge graph nodes.
class KnowledgeNodesTable {
  KnowledgeNodesTable._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.knowledgeNodesTable} (
      id TEXT PRIMARY KEY,
      label TEXT NOT NULL,
      type TEXT NOT NULL,
      workspace_id TEXT NOT NULL,
      document_id TEXT,
      confidence REAL DEFAULT 1.0,
      frequency INTEGER DEFAULT 1,
      created_at INTEGER NOT NULL,
      FOREIGN KEY (workspace_id) REFERENCES ${DbConstants.workspacesTable} (id) ON DELETE CASCADE
    )
  ''';
}
