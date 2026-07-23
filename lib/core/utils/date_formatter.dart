/// Utility class for formatting dates and timestamps.
class DateFormatter {
  DateFormatter._();

  /// Converts a Unix timestamp (in milliseconds) to a readable string.
  static String formatTimestamp(int timestampMs) {
    if (timestampMs == 0) return 'Never';
    final date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Converts a Unix timestamp to a relative string (e.g., "2 hours ago").
  static String formatRelative(int timestampMs) {
    if (timestampMs == 0) return 'Never';
    
    final date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
