import 'package:equatable/equatable.dart';
import 'search_mode.dart';

class SearchFilter extends Equatable {

  const SearchFilter({
    this.fileTypes = const [],
    this.favoritesOnly = false,
    this.pinnedOnly = false,
    this.startDate,
    this.endDate,
    this.mode = SearchMode.hybrid,
  });
  final List<String> fileTypes;
  final bool favoritesOnly;
  final bool pinnedOnly;
  final DateTime? startDate;
  final DateTime? endDate;
  final SearchMode mode;

  SearchFilter copyWith({
    List<String>? fileTypes,
    bool? favoritesOnly,
    bool? pinnedOnly,
    DateTime? startDate,
    DateTime? endDate,
    SearchMode? mode,
  }) => SearchFilter(
      fileTypes: fileTypes ?? this.fileTypes,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      pinnedOnly: pinnedOnly ?? this.pinnedOnly,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      mode: mode ?? this.mode,
    );

  @override
  List<Object?> get props => [
        fileTypes,
        favoritesOnly,
        pinnedOnly,
        startDate,
        endDate,
        mode,
      ];
}
