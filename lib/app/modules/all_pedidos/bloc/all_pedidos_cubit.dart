import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/all_pedidos_api_service.dart';
import '../../../models/filter_option.dart';
import '../models/all_pedido_model.dart';
import 'all_pedidos_state.dart';
import '../../filter/cubit/filter_cubit.dart';

class AllPedidosCubit extends Cubit<AllPedidosState> {
  final AllPedidosApiService _apiService;
  late final FilterCubit _filterCubit;

  AllPedidosCubit(this._apiService) : super(AllPedidosState.initial()) {
    // ⭐ INICIALIZA O FILTER CUBIT PARA COMPARTILHAR ESTADO COM A UI
    _filterCubit = FilterCubit([]);
  }

  FilterCubit get filterCubit => _filterCubit;

  Future<void> loadInitialPedidos() async {
    emit(state.copyWith(isLoading: true, isFirstLoad: true, items: []));
    await _fetchPage(1);
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    debugPrint('🟡 [AllPedidosCubit] loadMore - Página atual: ${state.filter.page}');
    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextFilter = state.filter.copyWith(
        page: state.filter.page + 1,
      );

      debugPrint('🟡 [AllPedidosCubit] loadMore - Nova página: ${nextFilter.page}');
      final data = await _apiService.fetchPedidos(nextFilter);

      final List rawItems = data['items'] ?? [];
      final List<AllPedido> newItems = rawItems.map((json) => AllPedido.fromJson(json)).toList();
      
      final bool hasMore = data['pagination']?['next_page_url'] != null || data['next_page_url'] != null;
      final int total = data['pagination']?['total'] ?? data['total'] ?? state.total;

      emit(state.copyWith(
        items: [...state.items, ...newItems],
        isLoadingMore: false,
        filter: nextFilter,
        currentFilters: nextFilter.toQueryParams(),
        hasMore: hasMore,
        total: total,
      ));
      
      debugPrint('🟢 [AllPedidosCubit] loadMore finalizado. Total itens: ${state.items.length}');
    } catch (e) {
      debugPrint('🔴 [AllPedidosCubit] loadMore - Erro: $e');
      emit(state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> applyFilters({String? search, String? status, String? periodo}) async {
    debugPrint('🟡 [AllPedidosCubit] applyFilters: status=$status, periodo=$periodo, search=$search');
    
    final newFilter = state.filter.copyWith(
      status: status ?? 'todos',
      periodo: periodo ?? 'hoje',
      search: search ?? '',
      page: 1,
    );
    
    // ⭐ REFRESH SILENCIOSO (não emite loading global para não travar a UI)
    emit(state.copyWith(
      filter: newFilter,
      currentFilters: newFilter.toQueryParams(),
      clearError: true,
    ));
    
    await _fetchPage(1);
  }

  Future<void> clearFilters() async {
    _filterCubit.clearFilters();
    await applyFilters(status: 'todos', periodo: 'hoje', search: '');
  }

  Future<void> _fetchPage(int page) async {
    try {
      final currentFilter = state.filter.copyWith(page: page);
      final data = await _apiService.fetchPedidos(currentFilter);

      final List rawItems = data['items'] ?? [];
      final List<AllPedido> newItems = rawItems.map((json) => AllPedido.fromJson(json)).toList();
      
      final Map<String, int> resumo = Map<String, int>.from(data['resumo'] ?? {});
      
      // ⭐ CONSTRUIR FILTER GROUPS
      final List<FilterGroup> filterGroups = [];
      if (data['filter_options'] != null) {
        final rawOptions = data['filter_options'] as Map<String, dynamic>;
        rawOptions.forEach((key, value) {
          if (value is List) {
            FilterGroup group = FilterGroup.fromJson(key, value);
            
            // 🔥 Sincroniza o selectedValue do grupo com o estado do Cubit
            if (key == 'status') {
              group = group.copyWith(selectedValue: state.filter.status ?? 'todos');
            } else if (key == 'periodo') {
              group = group.copyWith(selectedValue: state.filter.periodo ?? 'hoje');
            }
            
            filterGroups.add(group);
          }
        });
      }
      
      final bool hasMore = data['pagination']?['next_page_url'] != null || data['next_page_url'] != null;
      final int total = data['pagination']?['total'] ?? data['total'] ?? 0;

      emit(state.copyWith(
        items: page == 1 ? newItems : [...state.items, ...newItems],
        isLoading: false,
        isFirstLoad: false,
        isLoadingMore: false,
        resumo: resumo,
        filterGroups: filterGroups,
        currentFilters: currentFilter.toQueryParams(),
        hasMore: hasMore,
        total: total,
      ));
      
      debugPrint('🟢 [AllPedidosCubit] _fetchPage($page) finalizado. Total itens: ${state.items.length}');
    } catch (e) {
      debugPrint('🔴 [AllPedidosCubit] _fetchPage($page) - Erro: $e');
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
        isFirstLoad: false,
        isLoadingMore: false,
      ));
    }
  }

  Future<AllPedido> fetchPedidoDetail(int pedidoId) async {
    return await _apiService.fetchPedidoDetail(pedidoId);
  }

  Future<bool> updatePedidoStatus(int pedidoId, String newStatus) async {
    return await _apiService.updateStatus(pedidoId, newStatus);
  }

  Map<String, dynamic> get currentFilters => state.filter.toQueryParams();
}
