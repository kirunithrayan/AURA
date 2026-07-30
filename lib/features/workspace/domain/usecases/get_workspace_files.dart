import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/workspace_file.dart';
import '../repositories/workspace_repository.dart';

class GetWorkspaceFiles {

  GetWorkspaceFiles(this.repository);
  final WorkspaceRepository repository;

  Future<Either<Failure, List<WorkspaceFile>>> call(String workspaceId) async => await repository.getWorkspaceFiles(workspaceId);
}
