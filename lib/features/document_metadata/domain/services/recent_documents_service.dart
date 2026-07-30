import 'package:dartz/dartz.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../entities/document_metadata.dart';
import '../../data/models/document_metadata_model.dart';
import '../../data/cache/metadata_cache.dart';

class RecentDocumentsService {

  RecentDocumentsService(this.dbHelper, this.cache);
  final DatabaseHelper dbHelper;
  final MetadataCache cache;

  Future<Either<Failure, List<DocumentMetadata>>> getRecentDocuments({int limit = 20}) async {
    try {
      final db = await dbHelper.database;
      final results = await db.query(
        DbConstants.workspaceFilesTable,
        where: 'last_opened_at IS NOT NULL',
        orderBy: 'last_opened_at DESC',
        limit: limit,
      );

      final documents = results.map((map) {
        final doc = DocumentMetadataModel.fromMap(map);
        cache.put(doc.id, doc);
        return doc;
      }).toList();

      return Right(documents);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get recent documents: $e'));
    }
  }

  Future<Either<Failure, void>> addRecentDocument(String id) async {
    try {
      final db = await dbHelper.database;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await db.rawUpdate('''
        UPDATE ${DbConstants.workspaceFilesTable} 
        SET last_opened_at = ?, open_count = open_count + 1 
        WHERE id = ?
      ''', [timestamp, id]);
      
      final cached = cache.get(id);
      if (cached != null) {
        cache.put(id, cached.copyWith(
          lastOpenedAt: timestamp, 
          openCount: cached.openCount + 1
        ));
      }
      
      AppLogger.info('RecentDocumentsService: Added $id to recent documents');
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add recent document: $e'));
    }
  }

  Future<Either<Failure, void>> removeRecentDocument(String id) async {
    try {
      final db = await dbHelper.database;
      await db.rawUpdate('''
        UPDATE ${DbConstants.workspaceFilesTable} 
        SET last_opened_at = NULL 
        WHERE id = ?
      ''', [id]);
      
      final cached = cache.get(id);
      if (cached != null) {
        cache.put(id, cached.copyWith(lastOpenedAt: null));
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to remove recent document: $e'));
    }
  }

  Future<Either<Failure, void>> clearHistory() async {
    try {
      final db = await dbHelper.database;
      await db.rawUpdate('''
        UPDATE ${DbConstants.workspaceFilesTable} 
        SET last_opened_at = NULL
      ''');
      
      // Update cache
      cache.clear(); // Simply clear the cache, or we would have to iterate
      AppLogger.info('RecentDocumentsService: Cleared history');
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to clear history: $e'));
    }
  }
}
