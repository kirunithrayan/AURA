import '../../domain/entities/workspace.dart';

/// Data model for Workspace, handles mapping to/from SQLite maps.
class WorkspaceModel extends Workspace {
  const WorkspaceModel({
    required super.id,
    required super.name,
    super.description,
    super.icon,
    super.color,
    required super.createdAt,
    required super.updatedAt,
    super.fileCount,
    super.totalSize,
    super.isPinned,
  });

  factory WorkspaceModel.fromEntity(Workspace entity) => WorkspaceModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      icon: entity.icon,
      color: entity.color,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      fileCount: entity.fileCount,
      totalSize: entity.totalSize,
      isPinned: entity.isPinned,
    );

  factory WorkspaceModel.fromMap(Map<String, dynamic> map) => WorkspaceModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      icon: map['icon'] as String?,
      color: map['color'] as int?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      fileCount: map['file_count'] as int? ?? 0,
      totalSize: map['total_size'] as int? ?? 0,
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
    );

  Map<String, dynamic> toMap() => {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'file_count': fileCount,
      'total_size': totalSize,
      'is_pinned': isPinned ? 1 : 0,
    };
}
