import 'package:equatable/equatable.dart';

class SearchFilter extends Equatable {
  final List<String> fileTypes;
  final bool favoritesOnly;
  final bool pinnedOnly;
  final DateTime? startDate;
  final DateTime? endDate;

  const SearchFilter({
    this.fileTypes = const [],
    this.favoritesOnly = false,
    this.pinnedOnly = false,
    this.startDate,
    this.endDate,
  });

  SearchFilter copyWith({
    List<String>? fileTypes,
    bool? favoritesOnly,
    bool? pinnedOnly,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return SearchFilter(
      fileTypes: fileTypes ?? this.fileTypes,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      pinnedOnly: pinnedOnly ?? this.pinnedOnly,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
        fileTypes,
        favoritesOnly,
        pinnedOnly,
        startDate,
        endDate,
      ];
}
