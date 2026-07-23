import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.totalWorkspaces,
    required super.totalDocuments,
    required super.totalStorageUsed,
  });
}
