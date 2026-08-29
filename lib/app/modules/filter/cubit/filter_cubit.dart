import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'filter_state.dart';
import '../../../models/filter_option.dart';
import '../../../utils/debounce.dart';

class FilterCubit extends Cubit<FilterState> {
  final Debounce _debounce = Debounce();

  FilterCubit(List<FilterGroup> initialGroups)
      : super(FilterState(groups: initialGroups));

  void setGroups(List<FilterGroup> newGroups) {
    // 🔥 Preserva as seleções atuais ao atualizar a estrutura vinda do backend
    final updatedGroups = newGroups.map((newGroup) {
      final existingGroup = state.groups.firstWhereOrNull((g) => g.key == newGroup.key);
      if (existingGroup != null) {
        return newGroup.copyWith(
          selectedValue: existingGroup.selectedValue,
          selectedValues: existingGroup.selectedValues,
        );
      }
      return newGroup;
    }).toList();

    if (const ListEquality().equals(updatedGroups, state.groups)) return;
    emit(state.copyWith(groups: updatedGroups));
  }

  void selectOption(String groupKey, String value) {
    debugPrint('🟡 [FilterCubit] selectOption: groupKey=$groupKey, value=$value');
    final groups = state.groups.map((group) {
      if (group.key == groupKey) {
        // 🔥 Lógica de Toggle Corrigida: 
        // Se clicar em 'todos', o valor passa a ser 'todos'.
        // Se clicar em um valor já selecionado, volta para 'todos'.
        String? nextValue;
        if (value == 'todos') {
          nextValue = 'todos';
        } else {
          nextValue = group.selectedValue == value ? 'todos' : value;
        }
        
        debugPrint('🟡 [FilterCubit] Proximo valor para $groupKey: $nextValue');
        return group.copyWith(selectedValue: nextValue);
      }
      return group;
    }).toList();
    
    if (const ListEquality().equals(groups, state.groups)) {
      debugPrint('🟡 [FilterCubit] Grupos iguais, ignorando');
      return;
    }
    
    emit(state.copyWith(groups: groups));
    _applyFilters();
  }

  void setSearch(String query) {
    if (state.searchQuery == query) return;
    debugPrint('🟡 [FilterCubit] setSearch: $query');
    emit(state.copyWith(searchQuery: query));
    _debounce(_applyFilters);
  }

  void clearFilters() {
    debugPrint('🟡 [FilterCubit] clearFilters');
    final clearedGroups = state.groups.map((group) {
      return group.copyWith(selectedValue: 'todos');
    }).toList();
    
    // 🔥 Mantemos o appliedParams atual para que o _applyFilters detecte a mudança
    emit(state.copyWith(
      groups: clearedGroups,
      searchQuery: '',
    ));
    
    // Força a aplicação para gerar o novo appliedParams e disparar o listener na UI
    _applyFilters(force: true);
  }

  void _applyFilters({bool force = false}) {
    final params = <String, dynamic>{};
    for (var group in state.groups) {
      // 🔥 Se o valor for 'todos' ou null, não incluímos na query params
      if (group.selectedValue != null && group.selectedValue != 'todos') {
        params[group.key] = group.selectedValue;
      }
    }
    if (state.searchQuery.isNotEmpty) {
      params['search'] = state.searchQuery;
    }
    
    debugPrint('🟡 [FilterCubit] _applyFilters: params=$params');

    if (!force && const MapEquality().equals(params, state.appliedParams)) {
      debugPrint('🟡 [FilterCubit] Params iguais, ignorando emissão de appliedParams');
      return;
    }
    
    emit(state.copyWith(appliedParams: params));
    debugPrint('🟡 [FilterCubit] Estado emitido com appliedParams=$params');
  }

  Map<String, dynamic> get currentParams => state.appliedParams;

  @override
  Future<void> close() {
    _debounce.dispose();
    return super.close();
  }
}
