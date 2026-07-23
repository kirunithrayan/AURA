import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/workspace_repository.dart';

class UnpinDocument {
  final WorkspaceRepository repository;

  UnpinDocument(this.repository);

  Future<Either<Failure, void>> call(String fileId, String workspaceId) async {
    return await repository.unpinDocument(fileId, workspaceId);
  }
}
