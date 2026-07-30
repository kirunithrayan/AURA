import 'dart:math';

/// Generates contextual snippets with highlighted match regions.
class SearchSnippetGenerator {

  const SearchSnippetGenerator({int snippetLength = 150})
      : _snippetLength = snippetLength;
  final int _snippetLength;

  /// Generates a contextual snippet from document content centered around the
  /// first match position with highlighted terms.
  ({String snippet, List<String> highlights}) generate({
    required String content,
    required List<String> matchedTokens,
    required List<int> matchPositions,
  }) {
    if (content.isEmpty || matchPositions.isEmpty) {
      return (snippet: '', highlights: matchedTokens);
    }

    // Use the first match position as the center of the snippet
    final centerPos = matchPositions.first;
    final halfLen = _snippetLength ~/ 2;

    final start = max(0, centerPos - halfLen);
    final end = min(content.length, centerPos + halfLen);

    String snippet = content.substring(start, end).replaceAll('\n', ' ').trim();

    // Add ellipsis indicators
    if (start > 0) snippet = '...$snippet';
    if (end < content.length) snippet = '$snippet...';

    return (
      snippet: snippet,
      highlights: matchedTokens,
    );
  }
}
