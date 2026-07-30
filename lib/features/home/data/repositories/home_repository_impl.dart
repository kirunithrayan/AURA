import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';
import '../../../workspace/domain/entities/workspace_file.dart';

class HomeRepositoryImpl implements HomeRepository {

  HomeRepositoryImpl({required this.localDataSource});
  final HomeLocalDataSource localDataSource;

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      final stats = await localDataSource.getDashboardStats();
      return Right(stats);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkspaceFile>>> getRecentDocuments(int limit) async {
    try {
      final docs = await localDataSource.getRecentDocuments(limit);
      return Right(docs);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkspaceFile>>> getGlobalPinnedDocuments() async {
    try {
      final docs = await localDataSource.getGlobalPinnedDocuments();
      return Right(docs);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
