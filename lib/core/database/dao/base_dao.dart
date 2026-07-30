import 'package:sqflite_sqlcipher/sqflite.dart';
import '../database_helper.dart';

/// A generic Data Access Object (DAO) helper providing standard CRUD utilities.
/// Local data sources should extend this to eliminate SQL boilerplate.
abstract class BaseDao<T> {

  BaseDao(this.dbHelper);
  final DatabaseHelper dbHelper;

  /// The name of the database table this DAO manages.
  String get tableName;

  /// Serializes the model [T] into a Map for SQLite insertion.
  Map<String, dynamic> toMap(T model);

  /// Deserializes a Map from SQLite into the model [T].
  T fromMap(Map<String, dynamic> map);

  /// Retrieves the initialized SQLCipher database instance.
  Future<Database> get db async => await dbHelper.database;

  /// ------------------------------------------------------------------------
  /// CRUD UTILITIES
  /// ------------------------------------------------------------------------

  /// Inserts a new record. By default, replaces if a conflict occurs.
  Future<int> insert(T model, {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
    final database = await db;
    return await database.insert(
      tableName,
      toMap(model),
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// Retrieves a single record by its primary key ID.
  Future<T?> getById(String id, {String idColumn = 'id'}) async {
    final database = await db;
    final results = await database.query(
      tableName,
      where: '$idColumn = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return fromMap(results.first);
    }
    return null;
  }

  /// Retrieves all records from the table with optional ordering and limiting.
  Future<List<T>> getAll({String? orderBy, int? limit, int? offset}) async {
    final database = await db;
    final results = await database.query(
      tableName,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return results.map(fromMap).toList();
  }

  /// Updates an existing record matching the provided ID.
  Future<int> update(String id, T model, {String idColumn = 'id'}) async {
    final database = await db;
    return await database.update(
      tableName,
      toMap(model),
      where: '$idColumn = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a record by its primary key ID.
  Future<int> delete(String id, {String idColumn = 'id'}) async {
    final database = await db;
    return await database.delete(
      tableName,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
  }

  /// Clears the entire table.
  Future<int> deleteAll() async {
    final database = await db;
    return await database.delete(tableName);
  }
}
