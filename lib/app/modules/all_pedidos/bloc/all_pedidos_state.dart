import 'package:equatable/equatable.dart';
import '../../../models/filter_option.dart';
import '../models/all_pedido_model.dart';

class AllPedidosFilter extends Equatable {
  final String? status;
  final String? periodo;
  final String? search;
  final int page;
  final int perPage;

  const AllPedidosFilter({
    this.status,
    this.periodo,
    this.search,
    this.page = 1,
    this.perPage = 20,
  });

  AllPedidosFilter copyWith({
    String? status,
    String? periodo,
    String? search,
    int? page,
    int? perPage,
  }) {
    return AllPedidosFilter(
      status: status ?? this.status,
      periodo: periodo ?? this.periodo,
      search: search ?? this.search,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }

  bool get hasFilters =>
      (status != null && status != 'todos' && status != '') ||
      (periodo != null && periodo != 'todos' && periodo != '') ||
      (search != null && search!.isNotEmpty);

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    // ⭐ SÓ ADICIONAR SE FOR DIFERENTE DE 'todos' OU NULL
    if (status != null && status!.isNotEmpty && status != 'todos') {
      params['status'] = status!;
    }
    
    // 🛠️ CORREÇÃO: Removida a verificação forçada de 'hoje'. 
    // Se for 'todos', não envia nada (o backend assume o padrão se necessário).
    if (periodo != null && periodo!.isNotEmpty && periodo != 'todos') {
      params['periodo'] = periodo!;
    }
    
    if (search != null && search!.isNotEmpty) {
      params['search'] = search!;
    }
    
    params['page'] = page;
    params['per_page'] = perPage;
    
    return params;
  }

  @override
  List<Object?> get props => [status, periodo, search, page, perPage];
}

class AllPedidosState extends Equatable {
  final List<AllPedido> items;
  final bool isLoading;
  final bool isFirstLoad;
  final bool isLoadingMore;
  final String? error;
  final List<FilterGroup> filterGroups;
  final Map<String, dynamic> currentFilters;
  final Map<String, int> resumo;
  final AllPedidosFilter filter;
  final bool hasMore;
  final int total;

  const AllPedidosState({
    required this.items,
    required this.isLoading,
    required this.isFirstLoad,
    required this.isLoadingMore,
    this.error,
    required this.filterGroups,
    required this.currentFilters,
    required this.resumo,
    required this.filter,
    required this.hasMore,
    required this.total,
  });

  factory AllPedidosState.initial() {
    return const AllPedidosState(
      items: [],
      isLoading: false,
      isFirstLoad: true,
      isLoadingMore: false,
      error: null,
      filterGroups: [],
      currentFilters: {},
      resumo: {},
      filter: AllPedidosFilter(),
      hasMore: true,
      total: 0,
    );
  }

  AllPedidosState copyWith({
    List<AllPedido>? items,
    bool? isLoading,
    bool? isFirstLoad,
    bool? isLoadingMore,
    String? error,
    List<FilterGroup>? filterGroups,
    Map<String, dynamic>? currentFilters,
    Map<String, int>? resumo,
    AllPedidosFilter? filter,
    bool? hasMore,
    int? total,
    bool clearError = false,
  }) {
    return AllPedidosState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isFirstLoad: isFirstLoad ?? this.isFirstLoad,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      filterGroups: filterGroups ?? this.filterGroups,
      currentFilters: currentFilters ?? this.currentFilters,
      resumo: resumo ?? this.resumo,
      filter: filter ?? this.filter,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [
        items,
        isLoading,
        isFirstLoad,
        isLoadingMore,
        error,
        filterGroups,
        currentFilters,
        resumo,
        filter,
        hasMore,
        total,
      ];
}
