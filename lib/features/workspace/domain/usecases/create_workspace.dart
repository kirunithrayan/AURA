import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/workspace.dart';
import '../repositories/workspace_repository.dart';

class CreateWorkspace {

  CreateWorkspace(this.repository);
  final WorkspaceRepository repository;

  Future<Either<Failure, Workspace>> call(Workspace workspace) async => await repository.createWorkspace(workspace);
}
