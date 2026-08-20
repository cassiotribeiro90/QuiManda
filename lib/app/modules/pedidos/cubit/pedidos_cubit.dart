import 'package:flutter_bloc/flutter_bloc.dart';
import 'pedidos_state.dart';
import '../repository/pedidos_repository.dart';
import '../model/pedido_action_response.dart';

class PedidosCubit extends Cubit<PedidosState> {
  final PedidoRepository _repository;

  // 🔥 Manter o estado atual para fazer merge
  PedidosLoaded? _currentLoadedState;

  PedidosCubit(this._repository) : super(PedidosInitial());

  // 🔥 Carregar pedidos ativos
  Future<void> carregarPedidosAtivos({
    bool silencioso = false,
    bool forceRefresh = true,
  }) async {
    // Se for silencioso e já tem dados, não mostra loading global
    if (!silencioso) {
      emit(PedidosLoading());
    } else if (_currentLoadedState != null) {
      emit(_currentLoadedState!.copyWith(isLoading: true));
    }

    try {
      final data = await _repository.listarAtivosAgrupados(
        forceRefresh: forceRefresh,
      );
      final groups = data['grupos'] as List? ?? [];
      final groupedModels = groups.map((e) => GrupoPedidos.fromJson(e)).toList();
      final total = groupedModels.fold(0, (sum, group) => sum + group.total);

      final novoEstado = PedidosLoaded(
        grupos: List<GrupoPedidos>.from(groupedModels),
        totalPedidos: total,
        isLoading: false,
      );

      _currentLoadedState = novoEstado;
      emit(novoEstado);
    } catch (e) {
      if (!silencioso) {
        emit(PedidosError(e.toString()));
      } else if (_currentLoadedState != null) {
        emit(_currentLoadedState!.copyWith(isLoading: false));
      }
    }
  }

  // 🔥 Refresh silencioso (background)
  Future<void> refreshSilencioso() async {
    await carregarPedidosAtivos(silencioso: true);
  }

  // 🔥 Refresh completo (pull-to-refresh)
  Future<void> refresh() async {
    await carregarPedidosAtivos(silencioso: false);
  }

  // 🔥 Aceitar pedido - atualiza direto com a resposta
  Future<void> aceitarPedido(int id) async {
    try {
      final response = await _repository.aceitar(id);
      
      if (response.grupos != null) {
        final total = response.grupos!.fold(0, (sum, group) => sum + group.total);
        final novoEstado = PedidosLoaded(
          grupos: response.grupos!,
          totalPedidos: total,
          isLoading: false,
        );
        _currentLoadedState = novoEstado;
        emit(novoEstado);
      } else {
        await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
      }
    } catch (e) {
      emit(PedidoActionError(e.toString()));
    }
  }

  // 🔥 Recusar pedido - atualiza direto com a resposta
  Future<void> recusarPedido(int id, {String? motivo, String? motivoCodigo}) async {
    try {
      final response = await _repository.recusar(id, motivo: motivo, motivoCodigo: motivoCodigo);
      
      if (response.grupos != null) {
        final total = response.grupos!.fold(0, (sum, group) => sum + group.total);
        final novoEstado = PedidosLoaded(
          grupos: response.grupos!,
          totalPedidos: total,
          isLoading: false,
        );
        _currentLoadedState = novoEstado;
        emit(novoEstado);
      } else {
        await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
      }
    } catch (e) {
      emit(PedidoActionError(e.toString()));
    }
  }

  // 🔥 Atualizar status - atualiza direto com a resposta
  Future<void> atualizarStatus(int id, String status, {String? motivo}) async {
    try {
      final response = await _repository.atualizarStatus(id, status, motivo: motivo);
      
      if (response.grupos != null) {
        final total = response.grupos!.fold(0, (sum, group) => sum + group.total);
        final novoEstado = PedidosLoaded(
          grupos: response.grupos!,
          totalPedidos: total,
          isLoading: false,
        );
        _currentLoadedState = novoEstado;
        emit(novoEstado);
      } else {
        await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
      }
    } catch (e) {
      emit(PedidoActionError(e.toString()));
    }
  }
}
