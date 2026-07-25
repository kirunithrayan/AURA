import 'dart:convert';
import '../../domain/entities/workspace_file.dart';

/// Data model for WorkspaceFile, handles mapping to/from SQLite maps.
class WorkspaceFileModel extends WorkspaceFile {
  const WorkspaceFileModel({
    required super.id,
    required super.workspaceId,
    required super.fileName,
    required super.filePath,
    super.originalPath,
    super.extension,
    super.mimeType,
    super.size,
    required super.createdAt,
    required super.modifiedAt,
    required super.importedAt,
    super.thumbnailPath,
    super.aiStage,
    super.contentHash,
    super.tags,
    super.lastOpenedAt,
    super.lastViewedPage,
    super.lastZoomLevel,
    super.lastScrollPosition,
  });

  factory WorkspaceFileModel.fromMap(Map<String, dynamic> map) {
    List<String> parsedTags = [];
    if (map['tags'] != null && (map['tags'] as String).isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(map['tags'] as String);
        parsedTags = decoded.map((e) => e.toString()).toList();
      } catch (e) {
        parsedTags = [];
      }
    }

    return WorkspaceFileModel(
      id: map['id'] as String,
      workspaceId: map['workspace_id'] as String,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      originalPath: map['original_path'] as String?,
      extension: map['extension'] as String?,
      mimeType: map['mime_type'] as String?,
      size: map['size'] as int?,
      createdAt: map['created_at'] as int,
      modifiedAt: map['modified_at'] as int,
      importedAt: map['imported_at'] as int,
      thumbnailPath: map['thumbnail_path'] as String?,
      aiStage: map['ai_stage'] as int? ?? 1,
      contentHash: map['content_hash'] as String?,
      tags: parsedTags,
      lastOpenedAt: map['last_opened_at'] as int?,
      lastViewedPage: map['last_viewed_page'] as int?,
      lastZoomLevel: map['last_zoom_level'] as double?,
      lastScrollPosition: map['last_scroll_position'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workspace_id': workspaceId,
      'file_name': fileName,
      'file_path': filePath,
      'original_path': originalPath,
      'extension': extension,
      'mime_type': mimeType,
      'size': size,
      'created_at': createdAt,
      'modified_at': modifiedAt,
      'imported_at': importedAt,
      'thumbnail_path': thumbnailPath,
      'ai_stage': aiStage,
      'content_hash': contentHash,
      'tags': jsonEncode(tags),
      'last_opened_at': lastOpenedAt,
      'last_viewed_page': lastViewedPage,
      'last_zoom_level': lastZoomLevel,
      'last_scroll_position': lastScrollPosition,
    };
  }

  factory WorkspaceFileModel.fromEntity(WorkspaceFile entity) {
    return WorkspaceFileModel(
      id: entity.id,
      workspaceId: entity.workspaceId,
      fileName: entity.fileName,
      filePath: entity.filePath,
      originalPath: entity.originalPath,
      extension: entity.extension,
      mimeType: entity.mimeType,
      size: entity.size,
      createdAt: entity.createdAt,
      modifiedAt: entity.modifiedAt,
      importedAt: entity.importedAt,
      thumbnailPath: entity.thumbnailPath,
      aiStage: entity.aiStage,
      contentHash: entity.contentHash,
      tags: entity.tags,
      lastOpenedAt: entity.lastOpenedAt,
      lastViewedPage: entity.lastViewedPage,
      lastZoomLevel: entity.lastZoomLevel,
      lastScrollPosition: entity.lastScrollPosition,
    );
  }
}
