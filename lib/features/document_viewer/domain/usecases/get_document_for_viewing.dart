import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import '../repositories/document_viewer_repository.dart';

class GetDocumentForViewing {

  GetDocumentForViewing(this.repository);
  final DocumentViewerRepository repository;

  Future<Either<Failure, WorkspaceFile>> call(String id) async => await repository.getDocumentForViewing(id);
}
