import '../../../domain/entities/indexing/search_index.dart';
import '../../../domain/entities/indexing/search_index_entry.dart';
import '../../../domain/entities/indexing/search_index_statistics.dart';
import '../tokenizer/abstract_tokenizer.dart';
import '../normalizer/abstract_token_normalizer.dart';
import '../filter/abstract_stop_word_filter.dart';
import 'abstract_index_builder.dart';

/// Default implementation of [AbstractIndexBuilder].
///
/// Orchestrates the pipeline: Tokenize → Normalize → Filter → Aggregate.
/// Each stage is injected and can be swapped independently.
class DefaultIndexBuilder implements AbstractIndexBuilder {

  const DefaultIndexBuilder(
    this._tokenizer,
    this._normalizer,
    this._stopWordFilter,
  );
  final AbstractTokenizer _tokenizer;
  final AbstractTokenNormalizer _normalizer;
  final AbstractStopWordFilter _stopWordFilter;

  @override
  ({SearchIndex index, SearchIndexStatistics statistics}) build({
    required String documentId,
    required String workspaceId,
    required String documentType,
    required String content,
    required String title,
    required String checksum,
    required String parserVersion,
  }) {
    final stopwatch = Stopwatch()..start();

    // Process both title and content as separate fields
    final titleEntries = _processField(title, 'title');
    final contentEntries = _processField(content, 'content');

    final allEntries = [...titleEntries, ...contentEntries];

    stopwatch.stop();

    // Calculate total token count (sum of all frequencies)
    int totalTokenCount = 0;
    for (final entry in allEntries) {
      totalTokenCount += entry.frequency;
    }

    final index = SearchIndex(
      documentId: documentId,
      workspaceId: workspaceId,
      documentType: documentType,
      indexedAt: DateTime.now(),
      wordCount: totalTokenCount,
      checksum: checksum,
      parserVersion: parserVersion,
      entries: allEntries,
    );

    final statistics = SearchIndexStatistics(
      tokenCount: totalTokenCount,
      uniqueTokenCount: allEntries.length,
      indexingDuration: stopwatch.elapsed,
      documentSize: content.length,
    );

    return (index: index, statistics: statistics);
  }

  List<SearchIndexEntry> _processField(String text, String field) {
    // 1. Tokenize
    final tokens = _tokenizer.tokenize(text);

    // 2. Normalize and filter, then aggregate
    final Map<String, _TokenAggregator> aggregator = {};

    for (final token in tokens) {
      final normalized = _normalizer.normalize(token.text);
      if (normalized.isEmpty) continue;
      if (!_stopWordFilter.shouldKeep(normalized)) continue;

      aggregator.putIfAbsent(normalized, () => _TokenAggregator(
        originalToken: token.text,
        field: field,
      ));
      aggregator[normalized]!.addPosition(token.position);
    }

    // 3. Build entries
    return aggregator.entries.map((e) {
      final agg = e.value;
      return SearchIndexEntry(
        normalizedToken: e.key,
        originalToken: agg.originalToken,
        frequency: agg.positions.length,
        positions: List.unmodifiable(agg.positions),
        field: agg.field,
      );
    }).toList();
  }
}

class _TokenAggregator {

  _TokenAggregator({required this.originalToken, required this.field});
  final String originalToken;
  final String field;
  final List<int> positions = [];

  void addPosition(int position) {
    positions.add(position);
  }
}
