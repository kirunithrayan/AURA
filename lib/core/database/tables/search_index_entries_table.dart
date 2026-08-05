import '../../constants/db_constants.dart';

class SearchIndexEntriesTable {
  SearchIndexEntriesTable._();

  static String get createTableQuery => '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.searchIndexEntriesTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      document_id TEXT NOT NULL,
      normalized_token TEXT NOT NULL,
      original_token TEXT NOT NULL,
      frequency INTEGER NOT NULL,
      positions TEXT NOT NULL,
      field TEXT NOT NULL,
      FOREIGN KEY (document_id) REFERENCES ${DbConstants.searchIndexesTable} (document_id) ON DELETE CASCADE
    )
  ''';
}
