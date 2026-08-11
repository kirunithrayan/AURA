import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';
import '../extensions/context_extensions.dart';
import 'aura_icon_button.dart';

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
/// Per-item actions are reached through an optional trailing overflow control:
/// pass [onMoreActions] and the caller opens an `AuraSheet` action surface.
/// When it is null (the default) no trailing control is rendered and the tile
/// is exactly as it was before, so surfaces with no actions are unaffected.
/// There is no persistent pin or state badge on the tile.
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
    this.onMoreActions,
  });

  final String title;
  final AuraFileType fileType;
  final VoidCallback onTap;
  final AuraDocumentTileVariant variant;
  final String? subtitle;
  final VoidCallback? onLongPress;
  final bool selected;

  /// Opens the document's action surface. Null renders no trailing control.
  /// Ignored by [AuraDocumentTileVariant.gridCell], which has no trailing slot.
  final VoidCallback? onMoreActions;

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

    final String composedLabel = sub == null ? title : '$title, $sub';
    // gridCell has no trailing slot, so it ignores the overflow control.
    final bool showMore = onMoreActions != null && !_isGrid;

    if (showMore) {
      // Two semantic nodes: the tile ("Open X") and the overflow button.
      return Semantics(
        explicitChildNodes: true,
        child: Material(
          color: selected ? colors.selectionBackground : colors.surfaceRaised,
          borderRadius: BorderRadius.circular(AuraRadius.md),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AuraRadius.md),
              border: Border.all(
                color: selected ? colors.actionPrimary : colors.borderDefault,
                width: AuraBorders.hairline,
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: selected,
                    label: 'Open $composedLabel',
                    child: InkWell(
                      onTap: onTap,
                      onLongPress: onLongPress,
                      borderRadius: BorderRadius.circular(AuraRadius.md),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AuraSpacing.componentPadding,
                        ),
                        child: ExcludeSemantics(child: content),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: AuraSpacing.gapTight),
                  child: AuraIconButton(
                    icon: Icons.more_vert,
                    tooltip: 'More actions for $title',
                    onPressed: onMoreActions,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      selected: selected,
      label: composedLabel,
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
