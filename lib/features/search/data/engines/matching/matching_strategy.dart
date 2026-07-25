import '../../../domain/entities/indexing/search_index_entry.dart';
import '../query/query_processor.dart';

/// Result of a matching operation on a single document's index.
class MatchResult {
  final String documentId;
  final double score;
  final List<int> matchPositions;
  final List<String> matchedTokens;
  final String matchReason;

  const MatchResult({
    required this.documentId,
    required this.score,
    required this.matchPositions,
    required this.matchedTokens,
    required this.matchReason,
  });
}

/// Contract for matching a processed query against index entries.
abstract class AbstractMatchingStrategy {
  MatchResult? match(
    ProcessedQuery query,
    List<SearchIndexEntry> entries,
    String documentId,
    String fileName,
  );
}

/// Default matching strategy supporting exact, prefix, multi-token, and phrase matching.
/// Designed for future extension to fuzzy matching.
class DefaultMatchingStrategy implements AbstractMatchingStrategy {
  static const double _exactMatchWeight = 10.0;
  static const double _prefixMatchWeight = 5.0;
  static const double _titleFieldBoost = 3.0;
  static const double _frequencyWeight = 1.5;

  const DefaultMatchingStrategy();

  @override
  MatchResult? match(
    ProcessedQuery query,
    List<SearchIndexEntry> entries,
    String documentId,
    String fileName,
  ) {
    if (query.isEmpty) return null;

    if (query.isPhraseSearch) {
      return _phraseMatch(query, entries, documentId, fileName);
    }

    return _multiTokenMatch(query, entries, documentId, fileName);
  }

  MatchResult? _multiTokenMatch(
    ProcessedQuery query,
    List<SearchIndexEntry> entries,
    String documentId,
    String fileName,
  ) {
    double totalScore = 0.0;
    final allPositions = <int>[];
    final matchedTokens = <String>{};
    final reasons = <String>[];

    // Check filename match (metadata-level)
    final lowerFileName = fileName.toLowerCase();
    for (final token in query.tokens) {
      if (lowerFileName.contains(token)) {
        totalScore += _exactMatchWeight * _titleFieldBoost;
        matchedTokens.add(token);
        if (!reasons.contains('Title match')) reasons.add('Title match');
      }
    }

    // Build a lookup map for O(1) access: normalizedToken -> entry
    final entryMap = <String, List<SearchIndexEntry>>{};
    for (final entry in entries) {
      entryMap.putIfAbsent(entry.normalizedToken, () => []).add(entry);
    }

    for (final queryToken in query.tokens) {
      // 1. Exact match
      final exactEntries = entryMap[queryToken];
      if (exactEntries != null) {
        for (final entry in exactEntries) {
          final fieldBoost = entry.field == 'title' ? _titleFieldBoost : 1.0;
          totalScore += _exactMatchWeight * fieldBoost + (entry.frequency * _frequencyWeight);
          allPositions.addAll(entry.positions);
          matchedTokens.add(queryToken);
          if (!reasons.contains('Exact match')) reasons.add('Exact match');
        }
        continue;
      }

      // 2. Prefix match
      bool prefixFound = false;
      for (final mapEntry in entryMap.entries) {
        if (mapEntry.key.startsWith(queryToken) && mapEntry.key != queryToken) {
          for (final entry in mapEntry.value) {
            final fieldBoost = entry.field == 'title' ? _titleFieldBoost : 1.0;
            totalScore += _prefixMatchWeight * fieldBoost + (entry.frequency * _frequencyWeight * 0.5);
            allPositions.addAll(entry.positions);
            matchedTokens.add(queryToken);
            prefixFound = true;
          }
        }
      }
      if (prefixFound && !reasons.contains('Prefix match')) {
        reasons.add('Prefix match');
      }
    }

    if (matchedTokens.isEmpty) return null;

    // Bonus for matching all query tokens
    if (matchedTokens.length == query.tokens.length && query.tokens.length > 1) {
      totalScore *= 1.5; // 50% bonus for full coverage
      reasons.add('All terms matched');
    }

    return MatchResult(
      documentId: documentId,
      score: totalScore,
      matchPositions: allPositions,
      matchedTokens: matchedTokens.toList(),
      matchReason: reasons.join(', '),
    );
  }

  MatchResult? _phraseMatch(
    ProcessedQuery query,
    List<SearchIndexEntry> entries,
    String documentId,
    String fileName,
  ) {
    if (query.tokens.isEmpty) return null;

    // For phrase matching, we need to find consecutive positions.
    // Build position lists per token.
    final tokenPositionMap = <String, List<List<int>>>{};
    for (final entry in entries) {
      tokenPositionMap.putIfAbsent(entry.normalizedToken, () => []).add(entry.positions);
    }

    // Check that all phrase tokens exist in the index
    for (final token in query.tokens) {
      if (!tokenPositionMap.containsKey(token)) {
        // Fall back to multi-token match if phrase can't be fully matched
        return _multiTokenMatch(query, entries, documentId, fileName);
      }
    }

    // Find consecutive position sequences
    final firstTokenPositions = <int>[];
    for (final posList in tokenPositionMap[query.tokens.first]!) {
      firstTokenPositions.addAll(posList);
    }
    firstTokenPositions.sort();

    int phraseHits = 0;
    final phrasePositions = <int>[];

    for (final startPos in firstTokenPositions) {
      bool fullMatch = true;
      for (int i = 1; i < query.tokens.length; i++) {
        final nextToken = query.tokens[i];
        final nextPositions = <int>[];
        for (final posList in tokenPositionMap[nextToken]!) {
          nextPositions.addAll(posList);
        }
        // Check if any position follows the previous token closely
        // (positions are character-level, so we check within a reasonable window)
        final expectedPos = startPos + (i * 8); // rough word-width estimate
        if (!nextPositions.any((p) => (p - expectedPos).abs() < 20)) {
          fullMatch = false;
          break;
        }
      }
      if (fullMatch) {
        phraseHits++;
        phrasePositions.add(startPos);
      }
    }

    if (phraseHits == 0) {
      // No exact phrase found; fall back to multi-token
      return _multiTokenMatch(query, entries, documentId, fileName);
    }

    final score = phraseHits * _exactMatchWeight * 2.0; // Double weight for phrase matches

    return MatchResult(
      documentId: documentId,
      score: score,
      matchPositions: phrasePositions,
      matchedTokens: query.tokens,
      matchReason: 'Phrase match ($phraseHits occurrences)',
    );
  }
}
