import 'package:flutter/foundation.dart';

enum LogCategory {
  general,
  search,
  database,
  ai,
  workspace,
  knowledgeGraph,
  personalization,
}

/// A lightweight, production-safe logging interface for AURA.
class AppLogger {
  AppLogger._();

  static void info(String message, {LogCategory category = LogCategory.general}) {
    if (!kReleaseMode) {
      debugPrint('[${_categoryName(category)}][INFO] $message');
    }
  }

  static void warning(String message, {LogCategory category = LogCategory.general}) {
    if (!kReleaseMode) {
      debugPrint('[${_categoryName(category)}][WARNING] $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace, LogCategory category = LogCategory.general]) {
    debugPrint('[${_categoryName(category)}][ERROR] $message');
    if (error != null) debugPrint('Exception: $error');
    if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
  }

  static String _categoryName(LogCategory category) {
    switch (category) {
      case LogCategory.search:
        return 'Search';
      case LogCategory.database:
        return 'Database';
      case LogCategory.ai:
        return 'AI';
      case LogCategory.workspace:
        return 'Workspace';
      case LogCategory.knowledgeGraph:
        return 'KnowledgeGraph';
      case LogCategory.personalization:
        return 'Personalization';
      case LogCategory.general:
        return 'App';
    }
  }
}
