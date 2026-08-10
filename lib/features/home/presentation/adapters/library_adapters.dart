import '../../../../core/widgets/aura_document_tile.dart';
import '../../../../core/widgets/aura_monogram.dart';
import '../../../document_viewer/core/utils/file_type_helper.dart';
import '../../../document_viewer/domain/entities/viewer_type.dart';

/// Presentation-layer adapters that map domain entities onto the Design System
/// display models used by the Library screen.
///
/// These live in the presentation layer so widgets never reach into repository
/// entities directly.

/// Derives a course identity color from a workspace's stable id.
///
/// STEP 6 COMPATIBILITY DECISION (approved 2026-08-10), not a Design System
/// rule: the Design System defines eight course-identity colors but AURA has no
/// authoritative course-color policy, and `Workspace.color` is a legacy nullable
/// ARGB value with no approved mapping onto those eight roles. Until such a
/// policy exists, the color is derived deterministically from the workspace's
/// stable id so the same course always renders the same color.
///
/// The derivation is intentionally a plain sum of code units rather than
/// `String.hashCode`, which is not guaranteed stable across Dart releases or
/// platforms. Nothing is persisted; replacing this function is the only change
/// required when an authoritative policy lands.
AuraCourseColor auraCourseColorForWorkspaceId(String workspaceId) {
  int accumulator = 0;
  for (final int unit in workspaceId.codeUnits) {
    accumulator = (accumulator + unit) % AuraCourseColor.values.length;
  }
  return AuraCourseColor.values[accumulator];
}

/// Maps a file extension onto the Design System's document glyph families.
///
/// Reuses the existing [FileTypeHelper] classification rather than introducing
/// a second extension-parsing abstraction.
AuraFileType auraFileTypeForExtension(String? extension) =>
    switch (FileTypeHelper.getViewerType(extension)) {
      ViewerType.pdf => AuraFileType.pdf,
      ViewerType.image => AuraFileType.image,
      ViewerType.text => AuraFileType.txt,
      ViewerType.docx => AuraFileType.doc,
      ViewerType.unsupported => AuraFileType.unknown,
    };
