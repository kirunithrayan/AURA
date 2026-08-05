// Regression coverage for candidate selection.
//
// Background: candidate selection used to append
// `AND (file_name LIKE ? OR tags LIKE ?)` for a non-empty keyword. That made
// the candidate set a *filename* search. KeywordSearchEngine returns early on
// an empty candidate set, so a term that appeared only in a document's body
// produced zero candidates, the search index was never consulted, and the
// lazy-index path could never fire. These tests hold the keyword out of
// candidate selection while proving the structural filters still work.

import 'package:flutter_test/flutter_test.dart';

import 'package:aura/core/constants/db_constants.dart';
import 'package:aura/features/search/data/datasources/local_search_datasource.dart';
import 'package:aura/features/search/domain/entities/search_query.dart';
import 'package:aura/features/search/domain/entities/search_filter.dart';

void main() {
  group('candidate selection ignores the keyword', () {
    test('a keyword adds no filename or tags predicate', () {
      final built = LocalSearchDatasource.buildCandidateQuery(
        const SearchQuery(keyword: 'fox'),
      );

      expect(built.sql, isNot(contains('file_name')),
          reason: 'body-only terms must not be filtered out by filename');
      expect(built.sql, isNot(contains('tags')));
      expect(built.sql, isNot(contains('LIKE')));
      // Only LIMIT and OFFSET are bound.
      expect(built.args, [20, 0]);
    });

    test('the query is identical with and without a keyword', () {
      final withKeyword = LocalSearchDatasource.buildCandidateQuery(
        const SearchQuery(keyword: 'quarterly budget review'),
      );
      final withoutKeyword = LocalSearchDatasource.buildCandidateQuery(
        const SearchQuery(keyword: ''),
      );

      expect(withKeyword.sql, withoutKeyword.sql);
      expect(withKeyword.args, withoutKeyword.args);
    });

    test('a keyword containing SQL wildcards is never interpolated', () {
      final built = LocalSearchDatasource.buildCandidateQuery(
        const SearchQuery(keyword: "100%_off'; DROP TABLE workspace_files;--"),
      );

      expect(built.sql, isNot(contains('DROP')));
      expect(built.sql, isNot(contains('%')));
      expect(built.args, [20, 0]);
    });
  });

  group('structural filters still apply', () {
    test('workspace scopes the candidate set', () {
      final built = LocalSearchDatasource.buildCandidateQuery(
        const SearchQuery(keyword: 'fox', workspaceId: 'ws-1'),
      );

      expect(built.sql, contains('AND workspace_id = ?'));
      expect(built.args, ['ws-1', 20, 0]);
    });

    test('file types bind one placeholder each', () {
      final built = LocalSearchDatasource.buildCandidateQuery(
        const SearchQuery(
          keyword: 'fox',
          filter: SearchFilter(fileTypes: ['pdf', 'txt', 'docx']),
        ),
      );

      expect(built.sql, contains('AND extension IN (?,?,?)'));
      expect(built.args, ['pdf', 'txt', 'docx', 20, 0]);
    });

    test('favorites and pinned are literal predicates, not bound args', () {
      final built = LocalSearchDatasource.buildCandidateQuery(
        const SearchQuery(
          keyword: 'fox',
          filter: SearchFilter(favoritesOnly: true, pinnedOnly: true),
        ),
      );

      expect(built.sql, contains('AND is_favorite = 1'));
      expect(built.sql, contains('AND is_pinned = 1'));
      expect(built.args, [20, 0]);
    });

    test('a date range binds epoch milliseconds', () {
      final start = DateTime.utc(2026, 1, 1);
      final end = DateTime.utc(2026, 12, 31);

      final built = LocalSearchDatasource.buildCandidateQuery(
        SearchQuery(
          keyword: 'fox',
          filter: SearchFilter(startDate: start, endDate: end),
        ),
      );

      expect(built.sql, contains('AND created_at >= ?'));
      expect(built.sql, contains('AND created_at <= ?'));
      expect(built.args, [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
        20,
        0,
      ]);
    });

    test('filters compose, and limit/offset stay last', () {
      final built = LocalSearchDatasource.buildCandidateQuery(
        const SearchQuery(
          keyword: 'fox',
          workspaceId: 'ws-1',
          limit: 50,
          offset: 100,
          filter: SearchFilter(fileTypes: ['pdf'], favoritesOnly: true),
        ),
      );

      expect(built.sql, startsWith(
          'SELECT * FROM ${DbConstants.workspaceFilesTable} WHERE 1=1'));
      expect(built.sql, endsWith(' LIMIT ? OFFSET ?'));
      expect(built.args, ['ws-1', 'pdf', 50, 100]);
    });

    test('no filters selects the whole workspace file table', () {
      final built = LocalSearchDatasource.buildCandidateQuery(
        const SearchQuery(keyword: 'fox'),
      );

      expect(
        built.sql,
        'SELECT * FROM ${DbConstants.workspaceFilesTable} WHERE 1=1'
        ' LIMIT ? OFFSET ?',
      );
    });
  });
}
