import '../../constants/db_constants.dart';

/// Table definition for workspace files.
class WorkspaceFilesTable {
  WorkspaceFilesTable._();

  static const String createTableQuery = '''
    CREATE TABLE ${DbConstants.workspaceFilesTable} (
      id TEXT PRIMARY KEY,
      workspace_id TEXT,
      file_name TEXT NOT NULL,
      file_path TEXT NOT NULL,
      original_path TEXT,
      extension TEXT,
      mime_type TEXT,
      size INTEGER,
      created_at INTEGER,
      modified_at INTEGER,
      imported_at INTEGER,
      thumbnail_path TEXT,
      ai_stage INTEGER DEFAULT 1,
      content_hash TEXT,
      tags TEXT,
      FOREIGN KEY (workspace_id) REFERENCES ${DbConstants.workspacesTable} (id) ON DELETE CASCADE
    )
  ''';
}
