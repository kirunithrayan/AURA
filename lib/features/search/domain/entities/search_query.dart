import 'package:equatable/equatable.dart';
import 'search_filter.dart';

class SearchQuery extends Equatable {
  final String keyword;
  final String? workspaceId;
  final SearchFilter filter;
  final int offset;
  final int limit;
  final String? sortField;
  final bool ascending;

  const SearchQuery({
    required this.keyword,
    this.workspaceId,
    this.filter = const SearchFilter(),
    this.offset = 0,
    this.limit = 20,
    this.sortField,
    this.ascending = false,
  });

  SearchQuery copyWith({
    String? keyword,
    String? workspaceId,
    SearchFilter? filter,
    int? offset,
    int? limit,
    String? sortField,
    bool? ascending,
  }) {
    return SearchQuery(
      keyword: keyword ?? this.keyword,
      workspaceId: workspaceId ?? this.workspaceId,
      filter: filter ?? this.filter,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      sortField: sortField ?? this.sortField,
      ascending: ascending ?? this.ascending,
    );
  }

  @override
  List<Object?> get props => [
        keyword,
        workspaceId,
        filter,
        offset,
        limit,
        sortField,
        ascending,
      ];
}
