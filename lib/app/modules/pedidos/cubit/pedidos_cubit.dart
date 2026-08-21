import 'package:flutter_bloc/flutter_bloc.dart';
import 'pedidos_state.dart';
import '../repository/pedidos_repository.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/utils/pedido_utils.dart';
import '../model/pedido_model.dart';

class PedidosCubit extends Cubit<PedidosState> {
  final PedidoRepository _repository;
  final TtsService _ttsService = TtsService();
  int? _currentStoreId; // 🔥 Armazena o ID da loja atual
  
  // 🔥 ARMAZENA OS IDs DOS PEDIDOS QUE JÁ FORAM ALERTADOS
  final Set<int> _alertedPedidos = {};

  // 🔥 Manter o estado atual para fazer merge
  PedidosLoaded? _currentLoadedState;

  PedidosCubit(this._repository) : super(PedidosInitial()) {
    // Inicializa o TTS quando o cubit é criado
    _ttsService.init();
  }

  // 🔥 CARREGAR PEDIDOS ATIVOS
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

      // 🔥 VERIFICA SE HÁ PEDIDOS NOVOS PARA ALERTAR EM LOOP
      _processNovosPedidos(groupedModels);

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

  /// 🔥 PROCESSAMENTO DE PEDIDOS NOVOS E FILTRAGEM DE ALERTAS
  void _processNovosPedidos(List<GrupoPedidos> grupos) {
    try {
      // 🔥 VERIFICA SE A LISTA DE GRUPOS É VÁLIDA
      // ignore: unnecessary_null_comparison
      if (grupos == null || grupos.isEmpty) {
        print('[PEDIDO_CUBIT] Nenhum grupo de pedidos para processar');
        _ttsService.filterAlerts([]);
        _alertedPedidos.clear();
        return;
      }

      // Encontra pedidos com status 'novo'
      final List<PedidoModel> novosItens = [];
      for (var grupo in grupos) {
        if (grupo != null && grupo.status == 'novo') {
          novosItens.addAll(grupo.itens);
        }
      }

      // 🔥 IDs DOS PEDIDOS QUE ESTÃO NOVOS (SEGURANÇA)
      final List<int> idsNovos = novosItens
          .where((p) => p != null)
          .map((p) => p.id)
          .toList();

      print('[PEDIDO_CUBIT] Pedidos novos encontrados: ${idsNovos.length}');

      // 🔥 FILTRA A FILA DO TTS: REMOVE ALERTAS DE PEDIDOS QUE NÃO SÃO MAIS NOVOS
      _ttsService.filterAlerts(idsNovos);

      // 🔥 ADICIONA ALERTAS PARA PEDIDOS NOVOS QUE AINDA NÃO FORAM ALERTADOS
      for (final pedido in novosItens) {
        // ignore: unnecessary_null_comparison
        if (pedido == null || pedido.id == null) {
          print('[PEDIDO_CUBIT] ⚠️ Pedido inválido ignorado');
          continue;
        }

        if (!_alertedPedidos.contains(pedido.id)) {
          _alertedPedidos.add(pedido.id);
          final alerta = PedidoUtils.formatarAlertaPedido(pedido);
          _ttsService.addAlert(pedido.id, alerta);
          print('[PEDIDO_CUBIT] 🔔 Alerta adicionado para pedido ${pedido.id}');
        }
      }

      // 🔥 LIMPA A LISTA DE ALERTADOS: MANTÉM APENAS OS QUE AINDA ESTÃO NA LISTA DE NOVOS
      _alertedPedidos.retainAll(idsNovos);
    } catch (e, stackTrace) {
      print('[PEDIDO_CUBIT] ❌ Erro ao processar pedidos novos: $e');
      print('[PEDIDO_CUBIT] StackTrace: $stackTrace');
    }
  }

  // 🔥 REGISTRA INTERAÇÃO DO USUÁRIO (necessário para Web)
  void registerUserInteraction() {
    _ttsService.onUserInteraction();
  }

  // 🔥 CARREGAR PEDIDOS COM VERIFICAÇÃO DE LOJA
  Future<void> loadPedidosAtivosWithStoreCheck(int storeId) async {
    // Se a loja mudou, recarrega
    if (_currentStoreId != storeId) {
      _currentStoreId = storeId;
      _alertedPedidos.clear();
      _ttsService.clearAlerts();
      await carregarPedidosAtivos();
    }
  }

  // 🔥 FORÇAR RECARREGAMENTO (usado quando a loja muda)
  Future<void> reloadForStoreChange() async {
    _currentStoreId = null; // Reseta para forçar recarregamento
    _alertedPedidos.clear();
    _ttsService.clearAlerts();
    await carregarPedidosAtivos();
  }

  // 🔥 MÉTODO PARA PROCESSAR NOVO PEDIDO (usado via socket ou push)
  Future<void> onNovoPedido(PedidoModel pedido) async {
    try {
      if (pedido != null && !_alertedPedidos.contains(pedido.id)) {
        _alertedPedidos.add(pedido.id);
        final alerta = PedidoUtils.formatarAlertaPedido(pedido);
        _ttsService.addAlert(pedido.id, alerta);
      }
      
      // Recarrega a lista de pedidos para atualizar a tela
      await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
    } catch (e) {
      print('[PEDIDO_CUBIT] Erro ao processar novo pedido: $e');
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

  // 🔥 ACEITAR PEDIDO
  Future<void> aceitarPedido(int id) async {
    // 🔥 Atualiza estado com o ID do pedido em processamento
    if (_currentLoadedState != null) {
      emit(_currentLoadedState!.copyWith(updatingPedidoId: id));
    }

    try {
      final response = await _repository.aceitar(id);
      
      // 🔥 REMOVE O ALERTA DO PEDIDO ACEITO IMEDIATAMENTE
      _removeAlert(id);

      if (response.grupos != null) {
        final total = response.grupos!.fold(0, (sum, group) => sum + group.total);
        
        // 🔥 RECALCULA ALERTAS COM A NOVA LISTA
        _processNovosPedidos(response.grupos!);

        final novoEstado = PedidosLoaded(
          grupos: response.grupos!,
          totalPedidos: total,
          isLoading: false,
          updatingPedidoId: null, // 🔥 Limpa o estado de atualização
        );
        _currentLoadedState = novoEstado;
        
        emit(novoEstado);
      } else {
        await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
      }
    } catch (e) {
      // 🔥 Em caso de erro, limpa o estado de atualização
      if (_currentLoadedState != null) {
        emit(_currentLoadedState!.copyWith(updatingPedidoId: null));
      }
      emit(PedidoActionError(e.toString()));
    }
  }

  // 🔥 RECUSAR PEDIDO
  Future<void> recusarPedido(int id, {String? motivo, String? motivoCodigo}) async {
    // 🔥 Atualiza estado com o ID do pedido em processamento
    if (_currentLoadedState != null) {
      emit(_currentLoadedState!.copyWith(updatingPedidoId: id));
    }

    try {
      final response = await _repository.recusar(id, motivo: motivo, motivoCodigo: motivoCodigo);
      
      // 🔥 REMOVE O ALERTA DO PEDIDO RECUSADO IMEDIATAMENTE
      _removeAlert(id);

      if (response.grupos != null) {
        final total = response.grupos!.fold(0, (sum, group) => sum + group.total);
        
        // 🔥 RECALCULA ALERTAS COM A NOVA LISTA
        _processNovosPedidos(response.grupos!);

        final novoEstado = PedidosLoaded(
          grupos: response.grupos!,
          totalPedidos: total,
          isLoading: false,
          updatingPedidoId: null, // 🔥 Limpa o estado de atualização
        );
        _currentLoadedState = novoEstado;

        emit(novoEstado);
      } else {
        await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
      }
    } catch (e) {
      // 🔥 Em caso de erro, limpa o estado de atualização
      if (_currentLoadedState != null) {
        emit(_currentLoadedState!.copyWith(updatingPedidoId: null));
      }
      emit(PedidoActionError(e.toString()));
    }
  }

  // 🔥 Atualizar status
  Future<void> atualizarStatus(int id, String status, {String? motivo}) async {
    // 🔥 Atualiza estado com o ID do pedido em processamento
    if (_currentLoadedState != null) {
      emit(_currentLoadedState!.copyWith(updatingPedidoId: id));
    }

    try {
      final response = await _repository.atualizarStatus(id, status, motivo: motivo);
      
      // 🔥 SE O NOVO STATUS NÃO É "NOVO", REMOVE O ALERTA
      if (status != 'novo') {
        _removeAlert(id);
      }

      if (response.grupos != null) {
        final total = response.grupos!.fold(0, (sum, group) => sum + group.total);

        // 🔥 RECALCULA ALERTAS COM A NOVA LISTA
        _processNovosPedidos(response.grupos!);

        final novoEstado = PedidosLoaded(
          grupos: response.grupos!,
          totalPedidos: total,
          isLoading: false,
          updatingPedidoId: null, // 🔥 Limpa o estado de atualização
        );
        _currentLoadedState = novoEstado;
        emit(novoEstado);
      } else {
        await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
      }
    } catch (e) {
      // 🔥 Em caso de erro, limpa o estado de atualização
      if (_currentLoadedState != null) {
        emit(_currentLoadedState!.copyWith(updatingPedidoId: null));
      }
      emit(PedidoActionError(e.toString()));
    }
  }

  // 🔥 REMOVE ALERTA DE UM PEDIDO ESPECÍFICO
  void _removeAlert(int pedidoId) {
    _ttsService.removeAlertByPedidoId(pedidoId);
    _alertedPedidos.remove(pedidoId);
    print('[PEDIDO_CUBIT] Alerta removido para pedido $pedidoId');
  }

  // 🔥 ALTERNAR MUDO DO TTS
  Future<void> toggleTtsMute() async {
    final isMuted = await _ttsService.toggleMute();
    print('[PEDIDO_CUBIT] TTS mudo: $isMuted');
    
    // Se desmutou e tem alertas, reinicia o loop
    if (!isMuted && _alertedPedidos.isNotEmpty) {
      // O loop iniciará automaticamente através do setMuted(false) no TtsService
    }

    if (_currentLoadedState != null) {
      emit(_currentLoadedState!.copyWith()); 
    }
  }

  // 🔥 GETTERS
  bool get isTtsMuted => _ttsService.isMuted;
  bool get isTtsLooping => _ttsService.isLooping;
  int get pendingAlertsCount => _ttsService.pendingAlertsCount;

  @override
  Future<void> close() {
    _ttsService.dispose();
    return super.close();
  }
}
