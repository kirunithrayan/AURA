/// Database table and column name constants for AURA.
class DbConstants {
  DbConstants._();

  // Database
  static const String databaseName = 'aura_secure.db';
  static const int databaseVersion = 10;
  static const String encryptionKeyAlias = 'aura_db_key';

  // Table Names
  static const String workspacesTable = 'workspaces';
  static const String workspaceFilesTable = 'workspace_files';
  static const String embeddingsTable = 'embeddings';
  static const String tagsTable = 'tags';
  static const String searchHistoryTable = 'search_history';
  static const String recentDocumentsTable = 'recent_documents';
  static const String pinnedDocumentsTable = 'pinned_documents';
  static const String schedulerQueueTable = 'scheduler_queue';
  static const String aiJobsTable = 'ai_jobs';
  static const String knowledgeNodesTable = 'knowledge_nodes';
  static const String knowledgeEdgesTable = 'knowledge_edges';
  static const String graphLayoutsTable = 'graph_layouts';
  static const String documentInteractionsTable = 'document_interactions';
  static const String searchInteractionsTable = 'search_interactions';
  static const String conversationSummariesTable = 'conversation_summaries';

  // Job Types (scheduler_queue)
  static const String jobTypeEmbedding = 'embedding';
  static const String jobTypeOcr = 'ocr';
  static const String jobTypeSummary = 'summary';
  static const String jobTypeTags = 'tags';
  static const String jobTypeGraph = 'graph';

  // AI Job Types (ai_jobs)
  static const String aiJobSummary = 'summary';
  static const String aiJobTags = 'tags';
  static const String aiJobCompare = 'compare';
  static const String aiJobDuplicates = 'duplicates';

  // Status Values
  static const String statusPending = 'pending';
  static const String statusRunning = 'running';
  static const String statusCompleted = 'completed';
  static const String statusFailed = 'failed';
  static const String statusCancelled = 'cancelled';

  // Execution Decisions
  static const String decisionExecute = 'execute';
  static const String decisionDelay = 'delay';
  static const String decisionBatch = 'batch';
  static const String decisionCancel = 'cancel';
  static const String decisionRetry = 'retry';

  // Search Types
  static const String searchKeyword = 'keyword';
  static const String searchSemantic = 'semantic';
  static const String searchHybrid = 'hybrid';

  // Relationship Types
  static const String relSemantic = 'semantic';
  static const String relTag = 'tag';
  static const String relTopic = 'topic';
  static const String relDuplicate = 'duplicate';
}
