import '../../constants/db_constants.dart';

/// Table definition for knowledge graph relationships.
class KnowledgeEdgesTable {
  KnowledgeEdgesTable._();

  static const String createTableQuery = '''
    CREATE TABLE ${DbConstants.knowledgeEdgesTable} (
      id TEXT PRIMARY KEY,
      source_file_id TEXT,
      target_file_id TEXT,
      relationship_type TEXT,
      weight REAL,
      workspace_id TEXT,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (source_file_id) REFERENCES ${DbConstants.workspaceFilesTable} (id) ON DELETE CASCADE,
      FOREIGN KEY (target_file_id) REFERENCES ${DbConstants.workspaceFilesTable} (id) ON DELETE CASCADE,
      FOREIGN KEY (workspace_id) REFERENCES ${DbConstants.workspacesTable} (id) ON DELETE CASCADE
    )
  ''';
}
