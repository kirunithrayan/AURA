import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/workspace_file.dart';
import '../repositories/workspace_repository.dart';

class GetWorkspaceFiles {
  final WorkspaceRepository repository;

  GetWorkspaceFiles(this.repository);

  Future<Either<Failure, List<WorkspaceFile>>> call(String workspaceId) async {
    return await repository.getWorkspaceFiles(workspaceId);
  }
}
