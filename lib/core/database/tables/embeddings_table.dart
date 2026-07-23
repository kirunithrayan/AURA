import '../../constants/db_constants.dart';

/// Table definition for document chunk embeddings.
class EmbeddingsTable {
  EmbeddingsTable._();

  static const String createTableQuery = '''
    CREATE TABLE ${DbConstants.embeddingsTable} (
      id TEXT PRIMARY KEY,
      file_id TEXT,
      chunk_index INTEGER,
      embedding BLOB,
      text_snippet TEXT,
      model_version TEXT,
      created_at INTEGER,
      FOREIGN KEY (file_id) REFERENCES ${DbConstants.workspaceFilesTable} (id) ON DELETE CASCADE
    )
  ''';
}
