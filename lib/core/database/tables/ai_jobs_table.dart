import '../../constants/db_constants.dart';

/// Table definition for AI job results (e.g., summaries, tags).
class AiJobsTable {
  AiJobsTable._();

  static const String createTableQuery = '''
    CREATE TABLE ${DbConstants.aiJobsTable} (
      id TEXT PRIMARY KEY,
      file_id TEXT,
      job_type TEXT,
      input_data TEXT,
      output_data TEXT,
      source_references TEXT,
      status TEXT,
      processing_time_ms INTEGER,
      created_at INTEGER,
      completed_at INTEGER,
      FOREIGN KEY (file_id) REFERENCES ${DbConstants.workspaceFilesTable} (id) ON DELETE CASCADE
    )
  ''';
}
