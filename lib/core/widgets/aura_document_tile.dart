import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';
import '../extensions/context_extensions.dart';

/// Document-tile variants. The Blueprint establishes four variants but does not
/// name them; these names are an implementation proposal.
enum AuraDocumentTileVariant { listRow, gridCell, searchResult, recent }

/// File-type families that drive the monochrome document glyph.
enum AuraFileType { pdf, doc, txt, image, unknown }

/// The universal document tile: one tappable, single-semantic-node component
/// that replaces the four legacy document renderings.
///
/// Monochrome glyph, two-line title (grows at large text scales rather than
/// truncating further), no file size and no counts.
///
/// Inline per-item actions (pin, insights, ...) are intentionally absent: the
/// Design System's one-node / no-nested-interactive rule conflicts with the
/// legacy inline actions, and that interaction model is an unresolved design
/// decision. Screens keep using the legacy tiles until it is settled.
class AuraDocumentTile extends StatelessWidget {
  const AuraDocumentTile({
    super.key,
    required this.title,
    required this.fileType,
    required this.onTap,
    this.variant = AuraDocumentTileVariant.listRow,
    this.subtitle,
    this.onLongPress,
    this.selected = false,
  });

  final String title;
  final AuraFileType fileType;
  final VoidCallback onTap;
  final AuraDocumentTileVariant variant;
  final String? subtitle;
  final VoidCallback? onLongPress;
  final bool selected;

  IconData get _glyph => switch (fileType) {
        AuraFileType.pdf => Icons.picture_as_pdf_outlined,
        AuraFileType.doc => Icons.description_outlined,
        AuraFileType.txt => Icons.article_outlined,
        AuraFileType.image => Icons.image_outlined,
        AuraFileType.unknown => Icons.insert_drive_file_outlined,
      };

  bool get _isGrid => variant == AuraDocumentTileVariant.gridCell;

  @override
  Widget build(BuildContext context) {
    final AuraColors colors = context.tokens.colors;
    final String? sub = subtitle;

    final Widget titleText = Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AuraTypography.titleSm.copyWith(color: colors.contentPrimary),
    );
    final Widget? subtitleText = sub == null
        ? null
        : Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AuraTypography.caption.copyWith(color: colors.contentSecondary),
          );
    final Widget glyph = Icon(
      _glyph,
      size: _isGrid ? AuraIconTokens.sizeLg : AuraIconTokens.sizeMd,
      color: colors.contentTertiary,
    );

    final Widget content = _isGrid
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              glyph,
              const SizedBox(height: AuraSpacing.componentGap),
              titleText,
              if (subtitleText != null) ...<Widget>[
                const SizedBox(height: AuraSpacing.gapMicro),
                subtitleText,
              ],
            ],
          )
        : Row(
            children: <Widget>[
              glyph,
              const SizedBox(width: AuraSpacing.componentGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    titleText,
                    if (subtitleText != null) ...<Widget>[
                      const SizedBox(height: AuraSpacing.gapMicro),
                      subtitleText,
                    ],
                  ],
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      selected: selected,
      label: sub == null ? title : '$title, $sub',
      child: Material(
        color: selected ? colors.selectionBackground : colors.surfaceRaised,
        borderRadius: BorderRadius.circular(AuraRadius.md),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AuraRadius.md),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AuraRadius.md),
              border: Border.all(
                color: selected ? colors.actionPrimary : colors.borderDefault,
                width: AuraBorders.hairline,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AuraSpacing.componentPadding),
              child: ExcludeSemantics(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
