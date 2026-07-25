import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../constants/db_constants.dart';

/// Handles database migrations between versions.
class DatabaseMigrations {
  DatabaseMigrations._();

  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN last_opened_at INTEGER');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN last_viewed_page INTEGER');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN last_zoom_level REAL');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN last_scroll_position REAL');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN open_count INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN page_count INTEGER');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN resolution TEXT');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN word_count INTEGER');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN paragraph_count INTEGER');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN character_count INTEGER');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN is_favorite INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN is_pinned INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN is_archived INTEGER DEFAULT 0');
    }
    if (oldVersion < 5) {
      await db.execute('CREATE INDEX IF NOT EXISTS idx_workspace_files_last_opened ON ${DbConstants.workspaceFilesTable} (last_opened_at)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_workspace_files_favorite ON ${DbConstants.workspaceFilesTable} (is_favorite)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_workspace_files_pinned ON ${DbConstants.workspaceFilesTable} (is_pinned)');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE ${DbConstants.searchHistoryTable} ADD COLUMN last_used INTEGER');
      await db.execute('ALTER TABLE ${DbConstants.searchHistoryTable} ADD COLUMN hit_count INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE ${DbConstants.searchHistoryTable} ADD COLUMN is_pinned INTEGER DEFAULT 0');
    }
  }
}
