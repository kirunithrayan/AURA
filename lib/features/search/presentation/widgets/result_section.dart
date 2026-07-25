import 'package:flutter/material.dart';
import '../../domain/entities/search_result.dart';
import 'search_result_card.dart';

class ResultSection extends StatelessWidget {
  final List<SearchResult> results;
  final ScrollController? scrollController;

  const ResultSection({
    super.key,
    required this.results,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return SearchResultCard(
          result: result,
          onTap: () {
            // Document View logic
          },
          onLongPress: () {
            // Context menu logic
          },
        );
      },
    );
  }
}
