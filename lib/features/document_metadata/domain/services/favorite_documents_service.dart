import 'package:dartz/dartz.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../entities/document_metadata.dart';
import '../../data/models/document_metadata_model.dart';
import '../../data/cache/metadata_cache.dart';

class FavoriteDocumentsService {

  FavoriteDocumentsService(this.dbHelper, this.cache);
  final DatabaseHelper dbHelper;
  final MetadataCache cache;

  Future<Either<Failure, List<DocumentMetadata>>> getFavorites() async {
    try {
      final db = await dbHelper.database;
      final results = await db.query(
        DbConstants.workspaceFilesTable,
        where: 'is_favorite = 1',
        orderBy: 'created_at DESC',
      );

      final documents = results.map((map) {
        final doc = DocumentMetadataModel.fromMap(map);
        cache.put(doc.id, doc);
        return doc;
      }).toList();

      return Right(documents);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get favorites: $e'));
    }
  }

  Future<Either<Failure, void>> addFavorite(String id) async => _updateFavoriteStatus(id, true);

  Future<Either<Failure, void>> removeFavorite(String id) async => _updateFavoriteStatus(id, false);

  Future<Either<Failure, void>> toggleFavorite(String id) async {
    try {
      final db = await dbHelper.database;
      final results = await db.query(
        DbConstants.workspaceFilesTable,
        columns: ['is_favorite'],
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isEmpty) {
        return const Left(DatabaseFailure('Document not found'));
      }

      final isFavorite = (results.first['is_favorite'] as int? ?? 0) == 1;
      return _updateFavoriteStatus(id, !isFavorite);
    } catch (e) {
      return Left(DatabaseFailure('Failed to toggle favorite: $e'));
    }
  }

  Future<Either<Failure, void>> _updateFavoriteStatus(String id, bool status) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        DbConstants.workspaceFilesTable,
        {'is_favorite': status ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );

      final cached = cache.get(id);
      if (cached != null) {
        cache.put(id, cached.copyWith(isFavorite: status));
      }
      
      AppLogger.info('FavoriteDocumentsService: Set favorite status of $id to $status');
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update favorite status: $e'));
    }
  }
}
