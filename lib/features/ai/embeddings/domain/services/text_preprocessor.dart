/// Service for preprocessing extracted text before chunking.
///
/// Normalizes whitespace, unicode, removes invalid control characters,
/// and prepares the text for optimal embedding quality.
class TextPreprocessor {
  const TextPreprocessor();

  /// Preprocesses the raw text.
  String preprocess(String text) {
    if (text.isEmpty) return text;

    String processed = text;

    // 1. Remove invalid control characters but keep newlines and tabs
    processed = processed.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    // 2. Normalize unicode (e.g. smart quotes to standard quotes)
    processed = processed.replaceAll('“', '"').replaceAll('”', '"');
    processed = processed.replaceAll('‘', "'").replaceAll('’', "'");
    processed = processed.replaceAll('–', '-').replaceAll('—', '-');

    // 3. Normalize whitespace while preserving paragraph boundaries
    // Replace 3+ newlines with exactly 2 newlines (paragraph boundary)
    processed = processed.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    // Replace multiple spaces/tabs within a line with a single space
    processed = processed.replaceAll(RegExp(r'[ \t]+'), ' ');

    // 4. Trim leading and trailing whitespace
    return processed.trim();
  }
}
