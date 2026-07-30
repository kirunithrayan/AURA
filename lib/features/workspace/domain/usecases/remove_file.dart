import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/workspace_repository.dart';

class RemoveFile {

  RemoveFile(this.repository);
  final WorkspaceRepository repository;

  Future<Either<Failure, void>> call(String fileId) async => await repository.removeFile(fileId);
}
