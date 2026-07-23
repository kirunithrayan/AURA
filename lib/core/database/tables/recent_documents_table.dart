import '../../constants/db_constants.dart';

/// Table definition for recently accessed documents.
class RecentDocumentsTable {
  RecentDocumentsTable._();

  static const String createTableQuery = '''
    CREATE TABLE ${DbConstants.recentDocumentsTable} (
      id TEXT PRIMARY KEY,
      file_id TEXT,
      accessed_at INTEGER,
      access_count INTEGER DEFAULT 1,
      FOREIGN KEY (file_id) REFERENCES ${DbConstants.workspaceFilesTable} (id) ON DELETE CASCADE
    )
  ''';
}
