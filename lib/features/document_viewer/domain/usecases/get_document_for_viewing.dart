import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../workspace/domain/entities/workspace_file.dart';
import '../repositories/document_viewer_repository.dart';

class GetDocumentForViewing {
  final DocumentViewerRepository repository;

  GetDocumentForViewing(this.repository);

  Future<Either<Failure, WorkspaceFile>> call(String id) async {
    return await repository.getDocumentForViewing(id);
  }
}
