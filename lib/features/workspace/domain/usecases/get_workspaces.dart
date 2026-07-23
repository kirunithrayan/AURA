import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/workspace.dart';
import '../repositories/workspace_repository.dart';

class GetWorkspaces {
  final WorkspaceRepository repository;

  GetWorkspaces(this.repository);

  Future<Either<Failure, List<Workspace>>> call() async {
    return await repository.getWorkspaces();
  }
}
