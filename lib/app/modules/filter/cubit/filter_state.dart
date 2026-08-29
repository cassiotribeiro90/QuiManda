import 'package:equatable/equatable.dart';
import '../../../models/filter_option.dart';

class FilterState extends Equatable {
  final List<FilterGroup> groups;
  final String searchQuery;
  final Map<String, dynamic> appliedParams;

  const FilterState({
    this.groups = const [],
    this.searchQuery = '',
    this.appliedParams = const {},
  });

  FilterState copyWith({
    List<FilterGroup>? groups,
    String? searchQuery,
    Map<String, dynamic>? appliedParams,
  }) {
    return FilterState(
      groups: groups ?? this.groups,
      searchQuery: searchQuery ?? this.searchQuery,
      appliedParams: appliedParams ?? this.appliedParams,
    );
  }

  @override
  List<Object?> get props => [groups, searchQuery, appliedParams];
}
