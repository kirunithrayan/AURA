import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/dashboard_stats.dart';
import '../../../workspace/domain/entities/workspace_file.dart';

abstract class HomeRepository {
  Future<Either<Failure, DashboardStats>> getDashboardStats();
  Future<Either<Failure, List<WorkspaceFile>>> getRecentDocuments(int limit);
  Future<Either<Failure, List<WorkspaceFile>>> getGlobalPinnedDocuments();
}
