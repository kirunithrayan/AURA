import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/workspace_repository.dart';

class RemoveFile {
  final WorkspaceRepository repository;

  RemoveFile(this.repository);

  Future<Either<Failure, void>> call(String fileId) async {
    return await repository.removeFile(fileId);
  }
}
