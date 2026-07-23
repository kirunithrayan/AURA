import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/workspace_repository.dart';

class PinDocument {
  final WorkspaceRepository repository;

  PinDocument(this.repository);

  Future<Either<Failure, void>> call(String fileId, String workspaceId) async {
    return await repository.pinDocument(fileId, workspaceId);
  }
}
