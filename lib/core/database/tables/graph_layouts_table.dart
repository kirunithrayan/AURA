import '../../constants/db_constants.dart';

/// Table definition for caching knowledge graph node positions.
class GraphLayoutsTable {
  GraphLayoutsTable._();

  static const String createTableQuery = '''
    CREATE TABLE ${DbConstants.graphLayoutsTable} (
      id TEXT PRIMARY KEY,
      workspace_id TEXT,
      file_id TEXT,
      x_position REAL,
      y_position REAL,
      cluster_id TEXT,
      updated_at INTEGER,
      FOREIGN KEY (workspace_id) REFERENCES ${DbConstants.workspacesTable} (id) ON DELETE CASCADE,
      FOREIGN KEY (file_id) REFERENCES ${DbConstants.workspaceFilesTable} (id) ON DELETE CASCADE
    )
  ''';
}
