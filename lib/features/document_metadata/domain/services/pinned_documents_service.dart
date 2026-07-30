import 'package:dartz/dartz.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../entities/document_metadata.dart';
import '../../data/models/document_metadata_model.dart';
import '../../data/cache/metadata_cache.dart';

class PinnedDocumentsService {

  PinnedDocumentsService(this.dbHelper, this.cache);
  final DatabaseHelper dbHelper;
  final MetadataCache cache;

  Future<Either<Failure, List<DocumentMetadata>>> getPinned(String workspaceId) async {
    try {
      final db = await dbHelper.database;
      final results = await db.query(
        DbConstants.workspaceFilesTable,
        where: 'is_pinned = 1 AND workspace_id = ?',
        whereArgs: [workspaceId],
        orderBy: 'created_at DESC',
      );

      final documents = results.map((map) {
        final doc = DocumentMetadataModel.fromMap(map);
        cache.put(doc.id, doc);
        return doc;
      }).toList();

      return Right(documents);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get pinned documents: $e'));
    }
  }

  Future<Either<Failure, void>> pin(String id) async => _updatePinnedStatus(id, true);

  Future<Either<Failure, void>> unpin(String id) async => _updatePinnedStatus(id, false);

  Future<Either<Failure, void>> togglePin(String id) async {
    try {
      final db = await dbHelper.database;
      final results = await db.query(
        DbConstants.workspaceFilesTable,
        columns: ['is_pinned'],
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isEmpty) {
        return const Left(DatabaseFailure('Document not found'));
      }

      final isPinned = (results.first['is_pinned'] as int? ?? 0) == 1;
      return _updatePinnedStatus(id, !isPinned);
    } catch (e) {
      return Left(DatabaseFailure('Failed to toggle pin: $e'));
    }
  }

  Future<Either<Failure, void>> _updatePinnedStatus(String id, bool status) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        DbConstants.workspaceFilesTable,
        {'is_pinned': status ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );

      final cached = cache.get(id);
      if (cached != null) {
        cache.put(id, cached.copyWith(isPinned: status));
      }
      
      AppLogger.info('PinnedDocumentsService: Set pinned status of $id to $status');
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update pinned status: $e'));
    }
  }
}
