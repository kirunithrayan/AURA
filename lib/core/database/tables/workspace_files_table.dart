import '../../constants/db_constants.dart';

/// Table definition for workspace files.
class WorkspaceFilesTable {
  WorkspaceFilesTable._();

  static const String createTableQuery = '''
    CREATE TABLE ${DbConstants.workspaceFilesTable} (
      id TEXT PRIMARY KEY,
      workspace_id TEXT,
      file_name TEXT NOT NULL,
      file_path TEXT NOT NULL,
      original_path TEXT,
      extension TEXT,
      mime_type TEXT,
      size INTEGER,
      created_at INTEGER,
      modified_at INTEGER,
      imported_at INTEGER,
      thumbnail_path TEXT,
      ai_stage INTEGER DEFAULT 1,
      content_hash TEXT,
      tags TEXT,
      last_opened_at INTEGER,
      last_viewed_page INTEGER,
      last_zoom_level REAL,
      last_scroll_position REAL,
      open_count INTEGER DEFAULT 0,
      page_count INTEGER,
      resolution TEXT,
      word_count INTEGER,
      paragraph_count INTEGER,
      character_count INTEGER,
      is_favorite INTEGER DEFAULT 0,
      is_pinned INTEGER DEFAULT 0,
      is_archived INTEGER DEFAULT 0,
      FOREIGN KEY (workspace_id) REFERENCES ${DbConstants.workspacesTable} (id) ON DELETE CASCADE
    )
  ''';
}
