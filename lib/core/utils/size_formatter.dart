import 'dart:math';

/// Utility class for formatting byte sizes into readable strings.
class SizeFormatter {
  SizeFormatter._();

  /// Formats bytes into a human-readable string (e.g., "1.2 MB").
  static String formatBytes(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return "0 B";
    
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    final i = (log(bytes) / log(1024)).floor();
    
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
