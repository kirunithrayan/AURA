import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/workspace.dart';
import '../entities/workspace_file.dart';

/// Repository interface for Workspace and File management.
abstract class WorkspaceRepository {
  // Workspace Operations
  Future<Either<Failure, List<Workspace>>> getWorkspaces();
  Future<Either<Failure, Workspace>> getWorkspaceById(String id);
  Future<Either<Failure, Workspace>> createWorkspace(Workspace workspace);
  Future<Either<Failure, Workspace>> updateWorkspace(Workspace workspace);
  Future<Either<Failure, void>> deleteWorkspace(String id);

  // File Operations
  Future<Either<Failure, List<WorkspaceFile>>> getWorkspaceFiles(String workspaceId);
  Future<Either<Failure, WorkspaceFile>> importFile(String workspaceId, String sourcePath);
  Future<Either<Failure, void>> removeFile(String fileId);
  
  // Pinning Operations (Interacts with pinned_documents table)
  Future<Either<Failure, List<WorkspaceFile>>> getPinnedDocuments(String workspaceId);
  Future<Either<Failure, void>> pinDocument(String fileId, String workspaceId);
  Future<Either<Failure, void>> unpinDocument(String fileId, String workspaceId);
}
