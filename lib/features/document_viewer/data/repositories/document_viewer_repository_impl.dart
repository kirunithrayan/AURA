import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../workspace/data/datasources/workspace_local_datasource.dart';
import '../../../workspace/domain/entities/workspace_file.dart';
import '../../domain/repositories/document_viewer_repository.dart';

class DocumentViewerRepositoryImpl implements DocumentViewerRepository {
  final WorkspaceLocalDataSource localDataSource;

  DocumentViewerRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, WorkspaceFile>> getDocumentForViewing(String id) async {
    try {
      final fileModel = await localDataSource.getFileById(id);
      return Right(fileModel);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateViewerState(
    String id, {
    int? lastOpenedAt,
    int? lastViewedPage,
    double? lastZoomLevel,
    double? lastScrollPosition,
  }) async {
    try {
      await localDataSource.updateFileViewerState(
        id,
        lastOpenedAt: lastOpenedAt,
        lastViewedPage: lastViewedPage,
        lastZoomLevel: lastZoomLevel,
        lastScrollPosition: lastScrollPosition,
      );
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
