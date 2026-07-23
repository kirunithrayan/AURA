import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/workspace.dart';
import '../repositories/workspace_repository.dart';

class UpdateWorkspace {
  final WorkspaceRepository repository;

  UpdateWorkspace(this.repository);

  Future<Either<Failure, Workspace>> call(Workspace workspace) async {
    return await repository.updateWorkspace(workspace);
  }
}
