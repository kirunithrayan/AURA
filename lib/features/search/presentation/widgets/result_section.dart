import 'package:flutter/material.dart';
import '../../domain/entities/search_result.dart';
import 'search_result_card.dart';

class ResultSection extends StatelessWidget {

  const ResultSection({
    super.key,
    required this.results,
    this.scrollController,
  });
  final List<SearchResult> results;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) => ListView.builder(
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
