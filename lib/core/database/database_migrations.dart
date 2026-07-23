import 'package:sqflite_sqlcipher/sqflite.dart';

/// Handles database migrations between versions.
class DatabaseMigrations {
  DatabaseMigrations._();

  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implement migration logic when databaseVersion is bumped.
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE ...');
    // }
  }
}
