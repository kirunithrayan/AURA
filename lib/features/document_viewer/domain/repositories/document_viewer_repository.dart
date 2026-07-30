import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';

abstract class DocumentViewerRepository {
  Future<Either<Failure, WorkspaceFile>> getDocumentForViewing(String id);
  Future<Either<Failure, void>> updateViewerState(
    String id, {
    int? lastOpenedAt,
    int? lastViewedPage,
    double? lastZoomLevel,
    double? lastScrollPosition,
  });
}
