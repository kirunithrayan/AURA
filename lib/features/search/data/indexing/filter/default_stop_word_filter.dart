import 'abstract_stop_word_filter.dart';

/// Default English stop-word filter using a configurable word set.
/// Designed for future localization by swapping in language-specific sets.
class DefaultStopWordFilter implements AbstractStopWordFilter {
  final Set<String> _stopWords;

  DefaultStopWordFilter({Set<String>? stopWords})
      : _stopWords = stopWords ?? _defaultEnglishStopWords;

  @override
  bool shouldKeep(String normalizedToken) {
    if (normalizedToken.isEmpty) return false;
    if (normalizedToken.length <= 1) return false;
    return !_stopWords.contains(normalizedToken);
  }

  static final Set<String> _defaultEnglishStopWords = {
    'a', 'an', 'and', 'are', 'as', 'at', 'be', 'been', 'but', 'by',
    'can', 'could', 'did', 'do', 'does', 'done', 'for', 'from',
    'had', 'has', 'have', 'he', 'her', 'him', 'his', 'how',
    'if', 'in', 'into', 'is', 'it', 'its',
    'just', 'may', 'me', 'might', 'my',
    'no', 'nor', 'not', 'now',
    'of', 'on', 'or', 'our', 'out',
    'shall', 'she', 'should', 'so', 'some',
    'than', 'that', 'the', 'their', 'them', 'then', 'there', 'these',
    'they', 'this', 'those', 'to', 'too',
    'up', 'us',
    'very',
    'was', 'we', 'were', 'what', 'when', 'where', 'which', 'while',
    'who', 'whom', 'why', 'will', 'with', 'would',
    'you', 'your',
  };
}
