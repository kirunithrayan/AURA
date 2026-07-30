import '../../constants/db_constants.dart';

class ConversationSummariesTable {
  ConversationSummariesTable._();

  static String get createTableQuery => '''
    CREATE TABLE IF NOT EXISTS ${DbConstants.conversationSummariesTable} (
      id TEXT PRIMARY KEY,
      workspace_id TEXT NOT NULL,
      summary TEXT NOT NULL,
      topics TEXT NOT NULL,
      message_count INTEGER NOT NULL,
      last_updated INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      FOREIGN KEY (workspace_id) REFERENCES ${DbConstants.workspacesTable} (id) ON DELETE CASCADE
    )
  ''';
}
