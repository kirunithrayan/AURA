import '../../constants/db_constants.dart';

/// Table definition for the Adaptive AI Scheduler queue.
class SchedulerQueueTable {
  SchedulerQueueTable._();

  static const String createTableQuery = '''
    CREATE TABLE ${DbConstants.schedulerQueueTable} (
      id TEXT PRIMARY KEY,
      file_id TEXT,
      job_type TEXT,
      priority_score REAL,
      alpha_file_importance REAL,
      beta_user_activity REAL,
      gamma_device_state REAL,
      delta_search_probability REAL,
      execution_decision TEXT,
      status TEXT,
      retry_count INTEGER DEFAULT 0,
      max_retries INTEGER DEFAULT 3,
      batch_id TEXT,
      created_at INTEGER,
      scheduled_at INTEGER,
      started_at INTEGER,
      completed_at INTEGER,
      processing_time_ms INTEGER,
      error_message TEXT,
      FOREIGN KEY (file_id) REFERENCES ${DbConstants.workspaceFilesTable} (id) ON DELETE CASCADE
    )
  ''';
}
