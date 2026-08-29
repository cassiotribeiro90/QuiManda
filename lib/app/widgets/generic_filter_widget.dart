import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../modules/filter/cubit/filter_cubit.dart';
import '../modules/filter/cubit/filter_state.dart';
import '../models/filter_option.dart';

class GenericFilterWidget extends StatefulWidget {
  final List<FilterGroup> groups;
  final void Function(Map<String, dynamic>) onApply;
  final int? totalItems;
  final Map<String, dynamic> initialFilters;

  const GenericFilterWidget({
    super.key,
    required this.groups,
    required this.onApply,
    this.totalItems,
    this.initialFilters = const {},
  });

  @override
  State<GenericFilterWidget> createState() => _GenericFilterWidgetState();
}

class _GenericFilterWidgetState extends State<GenericFilterWidget> {
  late FilterCubit _filterCubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // 🔥 Inicializa os grupos com as seleções vindas do initialFilters
    final initializedGroups = widget.groups.map((group) {
      if (widget.initialFilters.containsKey(group.key)) {
        return group.copyWith(selectedValue: widget.initialFilters[group.key]);
      }
      return group;
    }).toList();

    _filterCubit = FilterCubit(initializedGroups);
    
    if (widget.initialFilters['search'] != null) {
      _filterCubit.setSearch(widget.initialFilters['search']);
      _searchController.text = widget.initialFilters['search'];
    }
  }

  @override
  void didUpdateWidget(GenericFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.groups != oldWidget.groups) {
      _filterCubit.setGroups(widget.groups);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 [GenericFilterWidget] build chamado');
    return BlocProvider.value(
      value: _filterCubit,
      child: BlocConsumer<FilterCubit, FilterState>(
        listenWhen: (previous, current) {
          final changed = previous.appliedParams != current.appliedParams;
          debugPrint('🔵 [GenericFilterWidget] listenWhen: appliedParams mudou? $changed');
          return changed;
        },
        listener: (context, state) {
          debugPrint('🔵 [GenericFilterWidget] listener disparado: ${state.appliedParams}');
          widget.onApply(state.appliedParams);
        },
        builder: (context, state) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          debugPrint('🎨 [GenericFilterWidget] builder: groups=${state.groups.length}, searchQuery=${state.searchQuery}');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- BARRA DE BUSCA ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                  onChanged: (value) => _filterCubit.setSearch(value),
                ),
              ),
              
              // ---- SEÇÕES DE FILTRO (VERTICAL) ----
              ...state.groups.map((group) => _FilterSection(
                group: group,
                onSelected: (value) => _filterCubit.selectOption(group.key, value),
              )),

              // ---- RESUMO DOS FILTROS ATIVOS ----
              if (_hasActiveFilters(state))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _buildFilterSummary(state),
                ),

              // ---- CONTAGEM E BOTÃO LIMPAR ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.totalItems != null)
                      Text(
                        '${widget.totalItems} conversas',
                        style: theme.textTheme.bodySmall,
                      ),
                    if (_hasActiveFilters(state))
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          _filterCubit.clearFilters();
                        },
                        child: const Text('Limpar filtros'),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
            ],
          );
        },
      ),
    );
  }

  bool _hasActiveFilters(FilterState state) {
    return state.groups.any((g) => g.selectedValue != null && g.selectedValue != 'todos') ||
        state.searchQuery.isNotEmpty;
  }

  Widget _buildFilterSummary(FilterState state) {
    final theme = Theme.of(context);
    final labels = <String>[];
    
    for (var group in state.groups) {
      if (group.selectedValue != null && group.selectedValue != 'todos') {
        final option = group.options.firstWhere(
          (o) => o.value == group.selectedValue,
          orElse: () => FilterOption(value: '', label: group.selectedValue!),
        );
        labels.add(option.label);
      }
    }
    
    if (state.searchQuery.isNotEmpty) {
      labels.add("'${state.searchQuery}'");
    }
    
    return Text(
      labels.join(' · '),
      style: TextStyle(
        fontSize: 12,
        color: theme.primaryColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterCubit.close();
    super.dispose();
  }
}

class _FilterSection extends StatelessWidget {
  final FilterGroup group;
  final void Function(String) onSelected;

  const _FilterSection({required this.group, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: group.options.map((option) {
              // 🔥 Lógica de Seleção Corrigida: 
              // Se group.selectedValue for null, seleciona apenas se o valor da opção for exatamente 'todos'.
              // Caso contrário, seleciona se o valor coincidir.
              final isSelected = (group.selectedValue == null && option.value == 'todos') || 
                                 (group.selectedValue == option.value);
                               
              return FilterChip(
                label: Text(option.label),
                selected: isSelected,
                onSelected: (_) => onSelected(option.value),
                selectedColor: theme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: theme.primaryColor,
                backgroundColor: theme.cardColor,
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? theme.primaryColor : null,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? theme.primaryColor : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
