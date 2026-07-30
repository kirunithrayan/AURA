import 'package:equatable/equatable.dart';

/// Domain entity representing a Workspace.
class Workspace extends Equatable {

  const Workspace({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.fileCount = 0,
    this.totalSize = 0,
    this.isPinned = false,
  });
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final int? color;
  final int createdAt;
  final int updatedAt;
  final int fileCount;
  final int totalSize;
  final bool isPinned;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        color,
        createdAt,
        updatedAt,
        fileCount,
        totalSize,
        isPinned,
      ];

  Workspace copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? color,
    int? createdAt,
    int? updatedAt,
    int? fileCount,
    int? totalSize,
    bool? isPinned,
  }) => Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fileCount: fileCount ?? this.fileCount,
      totalSize: totalSize ?? this.totalSize,
      isPinned: isPinned ?? this.isPinned,
    );
}
