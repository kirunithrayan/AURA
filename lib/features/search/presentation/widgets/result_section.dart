import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/aura_document_tile.dart';
import '../../../home/presentation/adapters/library_adapters.dart';
import '../../domain/entities/search_result.dart';

class ResultSection extends StatelessWidget {

  const ResultSection({
    super.key,
    required this.results,
    this.scrollController,
  });
  final List<SearchResult> results;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) => ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AuraSpacing.screenMargin,
        vertical: AuraSpacing.gapTight,
      ),
      itemCount: results.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: AuraSpacing.componentGap),
      itemBuilder: (context, index) {
        final result = results[index];
        // Search results carry no per-item actions, so no overflow control.
        return AuraDocumentTile(
          variant: AuraDocumentTileVariant.searchResult,
          title: result.metadata.fileName,
          fileType: auraFileTypeForExtension(result.metadata.fileExtension),
          onTap: () => context.pushNamed(
            AppRoutes.documentViewer,
            pathParameters: {'id': result.metadata.id},
          ),
        );
      },
    );
}
