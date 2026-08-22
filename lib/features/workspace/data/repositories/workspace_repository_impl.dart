import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/entities/workspace_file.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../datasources/workspace_local_datasource.dart';
import '../models/workspace_model.dart';
import '../models/workspace_file_model.dart';

import '../../../../services/file_service.dart';
import '../../../../services/thumbnail_service.dart';
import '../../../search/data/indexing/search_index_service.dart';
import '../../../search/domain/cache/abstract_search_cache.dart';

class WorkspaceRepositoryImpl implements WorkspaceRepository {

  WorkspaceRepositoryImpl({
    required this.localDataSource,
    required this.fileService,
    required this.thumbnailService,
    required this.searchIndexService,
    required this.searchCache,
  });
  final WorkspaceLocalDataSource localDataSource;
  final FileService fileService;
  final ThumbnailService thumbnailService;
  final SearchIndexService searchIndexService;
  final AbstractSearchCache searchCache;

  @override
  Future<Either<Failure, List<Workspace>>> getWorkspaces() async {
    try {
      final workspaces = await localDataSource.getWorkspaces();
      return Right(workspaces);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Workspace>> getWorkspaceById(String id) async {
    try {
      final workspace = await localDataSource.getWorkspaceById(id);
      return Right(workspace);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Workspace>> createWorkspace(Workspace workspace) async {
    try {
      final model = WorkspaceModel.fromEntity(workspace);
      final created = await localDataSource.createWorkspace(model);
      return Right(created);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Workspace>> updateWorkspace(Workspace workspace) async {
    try {
      final model = WorkspaceModel.fromEntity(workspace);
      final updated = await localDataSource.updateWorkspace(model);
      return Right(updated);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWorkspace(String id) async {
    try {
      await localDataSource.deleteWorkspace(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkspaceFile>>> getWorkspaceFiles(String workspaceId) async {
    try {
      final files = await localDataSource.getWorkspaceFiles(workspaceId);
      return Right(files);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  /// Not supported on this path.
  ///
  /// File import requires a `PlatformFile` from the platform file picker, which
  /// cannot be reconstructed from a bare path string. The picker runs in the
  /// presentation layer, which copies the file via [FileService] and then calls
  /// [persistImportedFile] with the resulting metadata.
  @override
  Future<Either<Failure, WorkspaceFile>> importFile(String workspaceId, String sourcePath) async =>
      const Left(FileSystemFailure(
        'importFile(path) is not supported. Use the file picker flow, which '
        'copies the file and calls persistImportedFile().',
      ));

  /// Internal helper to persist a picked and copied file to SQLite.
  /// Called by the ViewModel after using FileService to copy the file.
  Future<Either<Failure, WorkspaceFile>> persistImportedFile(String workspaceId, FileMetadata meta) async {
    try {
      final thumbnailPath = await thumbnailService.generateThumbnail(meta.filePath);
      
      final fileModel = WorkspaceFileModel(
        id: const Uuid().v4(),
        workspaceId: workspaceId,
        fileName: meta.fileName,
        filePath: meta.filePath,
        originalPath: meta.originalPath,
        extension: meta.extension,
        mimeType: meta.mimeType,
        size: meta.size,
        createdAt: meta.createdAt.millisecondsSinceEpoch,
        modifiedAt: meta.modifiedAt.millisecondsSinceEpoch,
        importedAt: DateTime.now().millisecondsSinceEpoch,
        thumbnailPath: thumbnailPath,
        contentHash: meta.contentHash,
        aiStage: 1, // Start at stage 1 (metadata only)
        tags: const [],
      );
      
      final saved = await localDataSource.addFile(fileModel);
      return Right(saved);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  /// Deletes a single file and everything it owns.
  ///
  /// The file is captured before deletion because once the workspace_files row
  /// is gone there is no way to recover which physical file and search index
  /// belonged to it. The database transaction inside [localDataSource.removeFile]
  /// is the single source of truth for success: if it throws, this returns a
  /// Failure and touches nothing else.
  ///
  /// Search-index removal and physical file deletion happen only after that
  /// transaction has committed, and are best-effort from there — a missing file
  /// or an index-cleanup error must not undo an already-committed deletion, so
  /// each is caught and logged rather than propagated. Only [filePath] (the
  /// AURA-owned copy) is ever deleted; [originalPath] points at the user's
  /// source file outside app storage and must never be removed.
  @override
  Future<Either<Failure, void>> removeFile(String fileId) async {
    try {
      final file = await localDataSource.getFileById(fileId);

      await localDataSource.removeFile(fileId);

      try {
        await searchIndexService.removeIndex(fileId);
      } catch (e, s) {
        AppLogger.error(
          'removeIndex failed while cleaning up deleted file $fileId',
          e,
          s,
          LogCategory.workspace,
        );
      }

      try {
        await fileService.deleteFile(file.filePath);
      } catch (e, s) {
        AppLogger.error(
          'deleteFile failed while cleaning up deleted file $fileId',
          e,
          s,
          LogCategory.workspace,
        );
      }

      searchCache.invalidate();

      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkspaceFile>>> getPinnedDocuments(String workspaceId) async {
    try {
      final files = await localDataSource.getPinnedDocuments(workspaceId);
      return Right(files);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> pinDocument(String fileId, String workspaceId) async {
    try {
      await localDataSource.pinDocument(fileId, workspaceId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unpinDocument(String fileId, String workspaceId) async {
    try {
      await localDataSource.unpinDocument(fileId, workspaceId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
