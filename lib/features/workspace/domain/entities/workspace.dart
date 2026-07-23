import 'package:equatable/equatable.dart';

/// Domain entity representing a Workspace.
class Workspace extends Equatable {
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
}
