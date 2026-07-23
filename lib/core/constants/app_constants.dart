/// Application-wide constants for AURA.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'AURA';
  static const String appFullName = 'Adaptive Unified Repository Assistant';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'AI-powered Knowledge Workspace for Android';

  // File Limits
  static const int maxFileSize = 50 * 1024 * 1024; // 50 MB
  static const int maxFilesPerImport = 20;
  static const int maxWorkspaces = 50;

  // AI Configuration
  static const int defaultEmbeddingDimensions = 384;
  static const int maxChunkSize = 512; // tokens
  static const int chunkOverlap = 64; // tokens
  static const int topKResults = 10;
  static const double similarityThreshold = 0.3;
  static const double duplicateThreshold = 0.85;
  static const int summaryTopNSentences = 5;
  static const int maxTagsPerDocument = 10;

  // Scheduler
  static const int schedulerIntervalMinutes = 15;
  static const int maxRetries = 3;
  static const int batchThreshold = 3;
  static const int delayMinutes = 30;

  // Cache
  static const int embeddingCacheMaxSize = 100;
  static const int thumbnailMaxWidth = 256;
  static const int thumbnailMaxHeight = 256;

  // Pagination
  static const int defaultPageSize = 20;
  static const int recentDocumentsLimit = 10;
  static const int dashboardRecentLimit = 3;
  static const int dashboardPinnedLimit = 3;

  // Supported File Extensions
  static const List<String> supportedExtensions = [
    'pdf', 'txt', 'md', 'doc', 'docx',
    'jpg', 'jpeg', 'png', 'webp', 'gif',
    'ppt', 'pptx', 'xls', 'xlsx', 'csv',
  ];

  static const List<String> imageExtensions = [
    'jpg', 'jpeg', 'png', 'webp', 'gif',
  ];

  static const List<String> documentExtensions = [
    'pdf', 'txt', 'md', 'doc', 'docx',
  ];
}
