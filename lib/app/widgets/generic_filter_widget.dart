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
                    hintText: 'Pesquisar...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? theme.colorScheme.surfaceContainerHighest
                        : Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => _filterCubit.setSearch(value),
                ),
              ),

              // ---- SEÇÕES DE FILTRO (VERTICAL) ----
              ...state.groups.map((group) => _FilterGroupChip(
                    group: group,
                    onSelected: (value) =>
                        _filterCubit.selectOption(group.key, value),
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
                        _hasActiveFilters(state)
                            ? 'Mostrando ${widget.totalItems! > 0 ? widget.totalItems : 0} resultados'
                            : 'Total: ${widget.totalItems} itens',
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
    return state.groups.any((g) {
          if (g.type == FilterType.multiple) {
            return g.selectedValues != null && g.selectedValues!.isNotEmpty;
          }
          return g.selectedValue != null && g.selectedValue != 'todos';
        }) ||
        state.searchQuery.isNotEmpty;
  }

  Widget _buildFilterSummary(FilterState state) {
    final theme = Theme.of(context);
    final labels = <String>[];

    for (var group in state.groups) {
      if (group.type == FilterType.multiple) {
        if (group.selectedValues != null && group.selectedValues!.isNotEmpty) {
          for (var val in group.selectedValues!) {
            final option = group.options.firstWhere(
              (o) => o.value == val,
              orElse: () => FilterOption(value: val, label: val),
            );
            labels.add(option.label);
          }
        }
      } else {
        if (group.selectedValue != null && group.selectedValue != 'todos') {
          final option = group.options.firstWhere(
            (o) => o.value == group.selectedValue,
            orElse: () =>
                FilterOption(value: '', label: group.selectedValue!),
          );
          labels.add(option.label);
        }
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

class _FilterGroupChip extends StatelessWidget {
  final FilterGroup group;
  final void Function(String) onSelected;

  const _FilterGroupChip({
    required this.group,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // IGNORA GRUPOS VAZIOS
    if (group.options.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do grupo
          Text(
            group.label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),

          // Opções - SEM ÍCONE DE CHECK
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: group.options.map((option) {
              final isOptionSelected = (group.selectedValue == null &&
                      option.value == 'todos') ||
                  (group.selectedValue == option.value) ||
                  (group.selectedValues?.contains(option.value) ?? false);

              return GestureDetector(
                onTap: () => onSelected(option.value),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isOptionSelected
                        ? theme.primaryColor
                        : (isDark
                            ? theme.colorScheme.surfaceContainerHigh
                            : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOptionSelected
                          ? theme.primaryColor
                          : (isDark
                              ? theme.colorScheme.outlineVariant
                              : Colors.grey[300]!),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔥 Mantém ícone do option se existir
                      if (option.icon != null) ...[
                        Text(option.icon!),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        option.count != null
                            ? '${option.label} (${option.count})'
                            : option.label,
                        style: TextStyle(
                          color: isOptionSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontSize: 13,
                          fontWeight: isOptionSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      // 🔥 NÃO ADICIONAR ÍCONE DE CHECK AQUI!
                    ],
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
