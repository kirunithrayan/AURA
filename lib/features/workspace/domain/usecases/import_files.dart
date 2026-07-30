import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../services/file_service.dart';
import '../entities/workspace_file.dart';
import '../repositories/workspace_repository.dart';
// Note: We cast to WorkspaceRepositoryImpl to access the specific persist method since 
// the abstract WorkspaceRepository interface wasn't initially designed for FileMetadata
import '../../data/repositories/workspace_repository_impl.dart';

class ImportFile {

  ImportFile(this.repository);
  final WorkspaceRepository repository;

  Future<Either<Failure, WorkspaceFile>> call(String workspaceId, FileMetadata meta) async {
    if (repository is WorkspaceRepositoryImpl) {
      return await (repository as WorkspaceRepositoryImpl).persistImportedFile(workspaceId, meta);
    }
    return const Left(FileSystemFailure('Repository implementation does not support advanced import'));
  }
}
