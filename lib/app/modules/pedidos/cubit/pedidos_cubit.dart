// lib/app/modules/pedidos/cubit/pedidos_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'pedidos_state.dart';
import '../repository/pedidos_repository.dart';

class PedidosCubit extends Cubit<PedidosState> {
  final PedidoRepository _repository;
  
  // 🔥 Manter o estado atual para fazer merge
  PedidosLoaded? _currentLoadedState;

  PedidosCubit(this._repository) : super(PedidosInitial());

  // 🔥 Carregar pedidos ativos
  Future<void> carregarPedidosAtivos({bool silencioso = false}) async {
    // 🔥 Se for silencioso e já tem dados, não mostra loading global, mas sim o flag no estado
    if (!silencioso) {
      emit(PedidosLoading());
    } else if (_currentLoadedState != null) {
      emit(_currentLoadedState!.copyWith(isLoading: true));
    }

    try {
      final data = await _repository.listarAtivosAgrupados(forceRefresh: !silencioso);
      final groups = data['grupos'] as List? ?? [];
      final groupedModels = groups.map((e) => GrupoPedidos.fromJson(e)).toList();
      final total = groupedModels.fold(0, (sum, group) => sum + group.total);

      final novoEstado = PedidosLoaded(
        grupos: groupedModels, 
        totalPedidos: total,
        isLoading: false,
      );
      
      _currentLoadedState = novoEstado;
      emit(novoEstado);
    } catch (e) {
      if (!silencioso) {
        emit(PedidosError(e.toString()));
      } else if (_currentLoadedState != null) {
        // Em caso de erro silencioso, volta para o estado anterior sem o flag de loading
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

  // 🔥 Aceitar pedido
  Future<void> aceitarPedido(int id) async {
    emit(PedidoAceitando(id));
    try {
      final pedido = await _repository.aceitar(id);
      emit(PedidoAceito(pedido));
      await carregarPedidosAtivos(silencioso: true);
    } catch (e) {
      emit(PedidoActionError(e.toString()));
    }
  }

  // 🔥 Recusar pedido
  Future<void> recusarPedido(int id, {String? motivo, String? motivoCodigo}) async {
    emit(PedidoRecusando(id));
    try {
      final pedido = await _repository.recusar(id, motivo: motivo, motivoCodigo: motivoCodigo);
      emit(PedidoRecusado(pedido));
      await carregarPedidosAtivos(silencioso: true);
    } catch (e) {
      emit(PedidoActionError(e.toString()));
    }
  }

  // 🔥 Atualizar status
  Future<void> atualizarStatus(int id, String status, {String? motivo}) async {
    // Usamos o loading global aqui para feedback visual imediato de mudança de status
    emit(PedidosLoading());
    try {
      await _repository.atualizarStatus(id, status, motivo: motivo);
      await carregarPedidosAtivos(silencioso: true);
    } catch (e) {
      emit(PedidosError(e.toString()));
    }
  }
}
