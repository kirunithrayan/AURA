import 'package:flutter/foundation.dart';

/// A lightweight logging interface for debugging.
class AppLogger {
  AppLogger._();

  static void info(String message) {
    debugPrint('[INFO] $message');
  }

  static void warning(String message) {
    debugPrint('[WARNING] $message');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('Exception: $error');
    if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
  }
}
