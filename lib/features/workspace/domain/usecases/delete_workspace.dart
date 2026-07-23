import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/workspace_repository.dart';

class DeleteWorkspace {
  final WorkspaceRepository repository;

  DeleteWorkspace(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteWorkspace(id);
  }
}
