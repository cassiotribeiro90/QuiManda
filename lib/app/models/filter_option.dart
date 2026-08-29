import 'package:equatable/equatable.dart';

enum FilterType { single, multiple }

class FilterOption extends Equatable {
  final String value;
  final String label;
  final int? count;

  const FilterOption({
    required this.value,
    required this.label,
    this.count,
  });

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'label': label,
        if (count != null) 'count': count,
      };

  @override
  List<Object?> get props => [value, label, count];
}

class FilterGroup extends Equatable {
  final String key;          // ex: 'periodo', 'status'
  final String label;        // ex: 'Período', 'Status'
  final FilterType type;
  final List<FilterOption> options;
  final String? selectedValue; // para tipo single
  final List<String>? selectedValues; // para tipo multiple

  const FilterGroup({
    required this.key,
    required this.label,
    this.type = FilterType.single,
    required this.options,
    this.selectedValue,
    this.selectedValues,
  });

  factory FilterGroup.fromJson(String key, dynamic data) {
    final list = data as List? ?? [];
    return FilterGroup(
      key: key,
      label: _mapKeyToLabel(key),
      type: FilterType.single, // todos são single no nosso caso
      options: list.map((e) => FilterOption.fromJson(e)).toList(),
    );
  }

  static String _mapKeyToLabel(String key) {
    switch (key) {
      case 'periodo':
        return 'Período';
      case 'status':
        return 'Status';
      case 'cliente_id':
        return 'Cliente';
      default:
        return key[0].toUpperCase() + key.substring(1);
    }
  }

  FilterGroup copyWith({
    String? selectedValue,
    List<String>? selectedValues,
  }) {
    return FilterGroup(
      key: key,
      label: label,
      type: type,
      options: options,
      selectedValue: selectedValue ?? this.selectedValue,
      selectedValues: selectedValues ?? this.selectedValues,
    );
  }

  @override
  List<Object?> get props => [key, label, type, options, selectedValue, selectedValues];
}
