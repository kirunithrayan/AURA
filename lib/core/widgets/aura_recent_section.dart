import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';
import 'aura_document_tile.dart';
import 'aura_section_header.dart';

/// Display data for one row in an [AuraRecentSection].
@immutable
class AuraRecentDocumentData {
  const AuraRecentDocumentData({
    required this.title,
    required this.fileType,
    required this.onTap,
    this.subtitle,
    this.onLongPress,
  });

  final String title;
  final AuraFileType fileType;
  final VoidCallback onTap;
  final String? subtitle;
  final VoidCallback? onLongPress;
}

/// A "recent documents" section: a vertical list of [AuraDocumentTile]s.
///
/// The section owns the spacing between tiles and its optional header.
class AuraRecentSection extends StatelessWidget {
  const AuraRecentSection({
    super.key,
    required this.documents,
    this.header,
  });

  final List<AuraRecentDocumentData> documents;
  final AuraSectionHeader? header;

  @override
  Widget build(BuildContext context) {
    final AuraSectionHeader? sectionHeader = header;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (sectionHeader != null) ...<Widget>[
          sectionHeader,
          const SizedBox(height: AuraSpacing.componentGap),
        ],
        for (int i = 0; i < documents.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: AuraSpacing.componentGap),
          AuraDocumentTile(
            title: documents[i].title,
            fileType: documents[i].fileType,
            onTap: documents[i].onTap,
            onLongPress: documents[i].onLongPress,
            subtitle: documents[i].subtitle,
            variant: AuraDocumentTileVariant.recent,
          ),
        ],
      ],
    );
  }
}
