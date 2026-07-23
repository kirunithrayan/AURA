import '../../constants/db_constants.dart';

/// Table definition for search history.
class SearchHistoryTable {
  SearchHistoryTable._();

  static const String createTableQuery = '''
    CREATE TABLE ${DbConstants.searchHistoryTable} (
      id TEXT PRIMARY KEY,
      query TEXT NOT NULL,
      search_type TEXT,
      result_count INTEGER,
      workspace_id TEXT,
      created_at INTEGER
    )
  ''';
}
