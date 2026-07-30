import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/workspace_repository.dart';

class DeleteWorkspace {

  DeleteWorkspace(this.repository);
  final WorkspaceRepository repository;

  Future<Either<Failure, void>> call(String id) async => await repository.deleteWorkspace(id);
}
