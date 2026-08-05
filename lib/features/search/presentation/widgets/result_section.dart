import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
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
          onTap: () => context.pushNamed(
            AppRoutes.documentViewer,
            pathParameters: {'id': result.metadata.id},
          ),
          onLongPress: () {
            // Context menu logic
          },
        );
      },
    );
}
