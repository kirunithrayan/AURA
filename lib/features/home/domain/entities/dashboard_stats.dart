import 'package:equatable/equatable.dart';

/// Domain entity representing aggregate statistics for the Home Dashboard.
class DashboardStats extends Equatable {

  const DashboardStats({
    required this.totalWorkspaces,
    required this.totalDocuments,
    required this.totalStorageUsed,
  });
  final int totalWorkspaces;
  final int totalDocuments;
  final int totalStorageUsed;

  @override
  List<Object?> get props => [
        totalWorkspaces,
        totalDocuments,
        totalStorageUsed,
      ];
}
