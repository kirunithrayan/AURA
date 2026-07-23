import '../../constants/db_constants.dart';

/// Table definition for workspace-scoped pinned documents.
class PinnedDocumentsTable {
  PinnedDocumentsTable._();

  static const String createTableQuery = '''
    CREATE TABLE ${DbConstants.pinnedDocumentsTable} (
      id TEXT PRIMARY KEY,
      file_id TEXT,
      workspace_id TEXT,
      pinned_at INTEGER,
      FOREIGN KEY (file_id) REFERENCES ${DbConstants.workspaceFilesTable} (id) ON DELETE CASCADE,
      FOREIGN KEY (workspace_id) REFERENCES ${DbConstants.workspacesTable} (id) ON DELETE CASCADE
    )
  ''';
}
