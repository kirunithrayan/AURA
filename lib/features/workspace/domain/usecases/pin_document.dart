import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/workspace_repository.dart';

class PinDocument {

  PinDocument(this.repository);
  final WorkspaceRepository repository;

  Future<Either<Failure, void>> call(String fileId, String workspaceId) async => await repository.pinDocument(fileId, workspaceId);
}
