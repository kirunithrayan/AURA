import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/workspace.dart';
import '../repositories/workspace_repository.dart';

class UpdateWorkspace {

  UpdateWorkspace(this.repository);
  final WorkspaceRepository repository;

  Future<Either<Failure, Workspace>> call(Workspace workspace) async => await repository.updateWorkspace(workspace);
}
