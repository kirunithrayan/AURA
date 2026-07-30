import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/workspace.dart';
import '../repositories/workspace_repository.dart';

class GetWorkspaces {

  GetWorkspaces(this.repository);
  final WorkspaceRepository repository;

  Future<Either<Failure, List<Workspace>>> call() async => await repository.getWorkspaces();
}
