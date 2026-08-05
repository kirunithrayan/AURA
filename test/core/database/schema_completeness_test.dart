// Guards the gap that let keyword search ship completely dead.
//
// `search_indexes` and `search_index_entries` were read and written all over
// the search feature, but neither was ever created in the schema. The DDL
// existed only inside a `SearchIndexLocalDatasource.ensureTables()` helper that
// nothing called. Every index read and write threw
// "no such table: search_indexes", so every query returned zero results.
//
// 94 unit tests passed throughout, because they all used fake engines and
// in-memory repositories that never touch the real schema. These tests read the
// actual source instead, so a table that the app talks to but the schema never
// creates fails here rather than on a user's device.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `static const String fooTable = 'foo';` in db_constants.dart
final _tableConstPattern =
    RegExp(r"static const String (\w*Table) = '(\w+)';");

/// `CREATE TABLE [IF NOT EXISTS] ${DbConstants.fooTable}` in a tables/*.dart
/// file. `IF NOT EXISTS` is used inconsistently across this codebase, so it is
/// optional here.
RegExp _createForConst(String constName) => RegExp(
    r'CREATE TABLE (?:IF NOT EXISTS )?\$\{DbConstants\.' + constName + r'\}');

String _read(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    fail('Expected to find $path relative to the package root (cwd: ${Directory.current.path})');
  }
  return file.readAsStringSync();
}

List<File> _dartFilesUnder(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

void main() {
  const constantsPath = 'lib/core/constants/db_constants.dart';
  const helperPath = 'lib/core/database/database_helper.dart';
  const tablesDir = 'lib/core/database/tables';

  late Map<String, String> tableConstants; // constName -> sql table name
  late String helperSource;

  setUpAll(() {
    final constantsSource = _read(constantsPath);
    tableConstants = {
      for (final m in _tableConstPattern.allMatches(constantsSource))
        m.group(1)!: m.group(2)!,
    };
    helperSource = _read(helperPath);
  });

  test('db_constants declares table names', () {
    expect(tableConstants, isNotEmpty,
        reason: 'Parser found no table constants — the pattern in this test is stale.');
    expect(tableConstants, containsPair('searchIndexesTable', 'search_indexes'));
    expect(tableConstants,
        containsPair('searchIndexEntriesTable', 'search_index_entries'));
  });

  test('every table the app talks to is created by the schema', () {
    final tableFiles = {
      for (final f in _dartFilesUnder(tablesDir)) f.path: f.readAsStringSync(),
    };
    final appSources = [
      ..._dartFilesUnder('lib/features'),
      ..._dartFilesUnder('lib/core'),
    ].where((f) => !f.path.endsWith('db_constants.dart'));

    final referenced = <String>{};
    for (final file in appSources) {
      final source = file.readAsStringSync();
      for (final constName in tableConstants.keys) {
        if (source.contains('DbConstants.$constName')) referenced.add(constName);
      }
    }

    final missing = <String>[];
    for (final constName in referenced) {
      // Find the tables/*.dart file whose CREATE TABLE targets this constant.
      final owner = tableFiles.entries
          .where((e) => _createForConst(constName).hasMatch(e.value))
          .toList();

      if (owner.isEmpty) {
        missing.add(
            '${tableConstants[constName]} ($constName): no CREATE TABLE in $tablesDir/');
        continue;
      }

      // That file's class must actually be wired into _onCreate.
      final className =
          RegExp(r'class (\w+)').firstMatch(owner.single.value)?.group(1);
      if (className == null || !helperSource.contains('$className.createTableQuery')) {
        missing.add(
            '${tableConstants[constName]} ($constName): $className is never used in _onCreate');
      }
    }

    expect(missing, isEmpty,
        reason: 'These tables are used by app code but never created:\n'
            '  ${missing.join('\n  ')}\n'
            'Every read and write against them throws "no such table" at runtime.');
  });

  test('search index tables are wired into _onCreate and the v11 migration', () {
    expect(helperSource, contains('SearchIndexesTable.createTableQuery'));
    expect(helperSource, contains('SearchIndexEntriesTable.createTableQuery'));

    final migrations = _read('lib/core/database/database_migrations.dart');
    expect(migrations, contains('oldVersion < 11'),
        reason: 'Existing installs need a migration, not just _onCreate.');
    expect(migrations, contains('SearchIndexesTable.createTableQuery'));
    expect(migrations, contains('SearchIndexEntriesTable.createTableQuery'));

    final constantsSource = _read(constantsPath);
    final version = RegExp(r'databaseVersion = (\d+)')
        .firstMatch(constantsSource)
        ?.group(1);
    expect(version, '11',
        reason: 'databaseVersion must be bumped so onUpgrade actually runs.');
  });

  test('datasources take table names from DbConstants, not string literals', () {
    // The missing tables hid behind private literals in the datasource, so they
    // never appeared alongside the other table names.
    final offenders = <String>[];
    for (final file in _dartFilesUnder('lib/features')) {
      if (!file.path.contains('datasource')) continue;
      final source = file.readAsStringSync();
      for (final m in RegExp(r"static const String (\w*[Tt]able\w*) = '(\w+)';")
          .allMatches(source)) {
        offenders.add('${file.path}: ${m.group(1)} = \'${m.group(2)}\'');
      }
    }

    expect(offenders, isEmpty,
        reason: 'Table names belong in DbConstants so the schema check above can see them:\n'
            '  ${offenders.join('\n  ')}');
  });
}
