import 'package:equatable/equatable.dart';

/// Domain entity representing a file inside a Workspace.
class WorkspaceFile extends Equatable {
  final String id;
  final String workspaceId;
  final String fileName;
  final String filePath;
  final String? originalPath;
  final String? extension;
  final String? mimeType;
  final int? size;
  final int createdAt;
  final int modifiedAt;
  final int importedAt;
  final String? thumbnailPath;
  final int aiStage;
  final String? contentHash;
  final List<String> tags;

  const WorkspaceFile({
    required this.id,
    required this.workspaceId,
    required this.fileName,
    required this.filePath,
    this.originalPath,
    this.extension,
    this.mimeType,
    this.size,
    required this.createdAt,
    required this.modifiedAt,
    required this.importedAt,
    this.thumbnailPath,
    this.aiStage = 1,
    this.contentHash,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
        id,
        workspaceId,
        fileName,
        filePath,
        originalPath,
        extension,
        mimeType,
        size,
        createdAt,
        modifiedAt,
        importedAt,
        thumbnailPath,
        aiStage,
        contentHash,
        tags,
      ];
}
