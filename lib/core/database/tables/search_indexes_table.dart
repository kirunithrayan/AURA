import '../../constants/db_constants.dart';

class SearchIndexesTable {
  SearchIndexesTable._();

  static String get createTableQuery => '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.searchIndexesTable} (
      document_id TEXT PRIMARY KEY,
      workspace_id TEXT NOT NULL,
      document_type TEXT NOT NULL,
      indexed_at INTEGER NOT NULL,
      word_count INTEGER NOT NULL,
      checksum TEXT NOT NULL,
      parser_version TEXT NOT NULL
    )
  ''';
}
