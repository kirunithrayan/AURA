import '../../constants/db_constants.dart';

/// Table definition for workspaces.
class WorkspacesTable {
  WorkspacesTable._();

  static const String createTableQuery = '''
    CREATE TABLE ${DbConstants.workspacesTable} (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      icon TEXT,
      color INTEGER,
      created_at INTEGER,
      updated_at INTEGER,
      file_count INTEGER DEFAULT 0,
      total_size INTEGER DEFAULT 0,
      is_pinned INTEGER DEFAULT 0
    )
  ''';
}
