/// Extension methods for [String].
extension StringExtensions on String {
  /// Capitalizes the first letter of the string.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Truncates the string to a maximum length and appends '...' if truncated.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Extracts the file extension from a file path or name.
  String get extension {
    final dotIndex = lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == length - 1) return '';
    return substring(dotIndex + 1).toLowerCase();
  }

  /// Checks if the string represents an image file based on extension.
  bool get isImage {
    final ext = extension;
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext);
  }

  /// Checks if the string represents a document file based on extension.
  bool get isDocument {
    final ext = extension;
    return ['pdf', 'txt', 'md', 'doc', 'docx'].contains(ext);
  }
}
