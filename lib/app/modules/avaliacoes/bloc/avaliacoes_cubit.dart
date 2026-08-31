// lib/app/modules/avaliacoes/bloc/avaliacoes_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../models/filter_option.dart';
import '../models/avaliacao_model.dart';
import '../services/avaliacao_service.dart';

abstract class AvaliacoesState extends Equatable {
  const AvaliacoesState();
  @override
  List<Object?> get props => [];
}

class AvaliacoesInitial extends AvaliacoesState {}

class AvaliacoesLoading extends AvaliacoesState {}

class AvaliacoesLoaded extends AvaliacoesState {
  final List<AvaliacaoModel> avaliacoes;
  final List<FilterGroup> filterGroups;
  final Map<String, dynamic> currentFilters;
  final int total;
  final bool hasMore;

  const AvaliacoesLoaded({
    required this.avaliacoes,
    required this.filterGroups,
    required this.currentFilters,
    required this.total,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [avaliacoes, filterGroups, currentFilters, total, hasMore];
}

class AvaliacoesError extends AvaliacoesState {
  final String message;
  const AvaliacoesError(this.message);
  @override
  List<Object> get props => [message];
}

class AvaliacoesCubit extends Cubit<AvaliacoesState> {
  final AvaliacaoService _service;
  Map<String, String> _currentFilters = {};

  AvaliacoesCubit(this._service) : super(AvaliacoesInitial());

  /// Carrega avaliações.
  /// - [silencioso]: se true, nunca emite AvaliacoesLoading.
  /// - Além disso, se já houver dados carregados (state is AvaliacoesLoaded),
  ///   mesmo sem `silencioso`, não emitirá loading (evita flicker).
  Future<void> carregar({
    String? status,
    int page = 1,
    bool isLoadMore = false,
    bool silencioso = false,
  }) async {
    // 🔥 Só mostra loading na PRIMEIRA carga (quando ainda não há dados)
    if (!isLoadMore && !silencioso && state is! AvaliacoesLoaded) {
      emit(AvaliacoesLoading());
    }

    try {
      final response = await _service.getAvaliacoes(
        status: status,
        page: page,
        perPage: 20,
      );

      final avaliacoes = response.avaliacoes;
      final total = response.total;
      final hasMore = response.hasMore;

      // Atualiza filtros atuais
      if (status != null && status != 'todos') {
        _currentFilters['status'] = status;
      } else {
        _currentFilters.remove('status');
      }

      // Sincroniza selectedValue nos grupos de filtro
      final filterGroups = response.filterGroups.map((group) {
        if (group.key == 'status') {
          return group.copyWith(
            selectedValue: _currentFilters['status'] ?? 'todos',
          );
        }
        return group;
      }).toList();

      final currentState = state;
      if (isLoadMore && currentState is AvaliacoesLoaded) {
        emit(AvaliacoesLoaded(
          avaliacoes: [...currentState.avaliacoes, ...avaliacoes],
          filterGroups: filterGroups,
          currentFilters: Map<String, dynamic>.from(_currentFilters),
          total: total,
          hasMore: hasMore,
        ));
      } else {
        emit(AvaliacoesLoaded(
          avaliacoes: avaliacoes,
          filterGroups: filterGroups,
          currentFilters: Map<String, dynamic>.from(_currentFilters),
          total: total,
          hasMore: hasMore,
        ));
      }
    } catch (e) {
      if (!silencioso) {
        emit(AvaliacoesError(e.toString()));
      }
    }
  }

  Future<void> carregarMais() async {
    final currentState = state;
    if (currentState is AvaliacoesLoaded && currentState.hasMore) {
      final nextPage = (currentState.total ~/ 20) + 1;
      await carregar(
        status: _currentFilters['status'],
        page: nextPage,
        isLoadMore: true,
      );
    }
  }

  Future<void> aprovar(int id) async {
    await _service.atualizarStatus(id, 'aprovado');
    await carregar(status: _currentFilters['status'], silencioso: true);
  }

  Future<void> rejeitar(int id) async {
    await _service.atualizarStatus(id, 'rejeitado');
    await carregar(status: _currentFilters['status'], silencioso: true);
  }

  Future<void> responder(int id, String resposta) async {
    await _service.responder(id, resposta);
    await carregar(status: _currentFilters['status'], silencioso: true);
  }
}