import '../../constants/db_constants.dart';

/// Table definition for global tags.
class TagsTable {
  TagsTable._();

  static const String createTableQuery = '''
    CREATE TABLE ${DbConstants.tagsTable} (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      color INTEGER,
      usage_count INTEGER DEFAULT 0,
      created_at INTEGER
    )
  ''';
}
