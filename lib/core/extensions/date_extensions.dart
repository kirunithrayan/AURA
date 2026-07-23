/// Extension methods for [DateTime].
extension DateExtensions on DateTime {
  /// Checks if this date is the same day as today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Checks if this date is the same day as yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Returns a clean relative string (e.g., "Today", "Yesterday", "2 days ago", or formatted date).
  String toRelativeString() {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    
    final difference = DateTime.now().difference(this).inDays;
    if (difference < 7) {
      return '$difference days ago';
    }
    
    return '${year.toString()}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
