import '../../constants/db_constants.dart';

class SearchInteractionsTable {
  SearchInteractionsTable._();

  static String get createTableQuery => '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.searchInteractionsTable} (
      id TEXT PRIMARY KEY,
      query TEXT NOT NULL,
      clicked_document_id TEXT,
      timestamp INTEGER NOT NULL,
      FOREIGN KEY (clicked_document_id) REFERENCES ${DbConstants.workspaceFilesTable} (id) ON DELETE SET NULL
    )
  ''';
}
