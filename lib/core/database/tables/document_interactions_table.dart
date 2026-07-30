import '../../constants/db_constants.dart';

class DocumentInteractionsTable {
  DocumentInteractionsTable._();

  static String get createTableQuery => '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.documentInteractionsTable} (
      id TEXT PRIMARY KEY,
      document_id TEXT NOT NULL,
      view_count INTEGER DEFAULT 0,
      reading_time_ms INTEGER DEFAULT 0,
      last_viewed_at INTEGER,
      FOREIGN KEY (document_id) REFERENCES ${DbConstants.workspaceFilesTable} (id) ON DELETE CASCADE
    )
  ''';
}
