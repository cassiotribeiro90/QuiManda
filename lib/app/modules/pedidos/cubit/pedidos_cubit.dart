import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/fcm_service.dart';
import 'pedidos_state.dart';
import '../repository/pedidos_repository.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/utils/pedido_utils.dart';
import '../model/pedido_model.dart';

class PedidosCubit extends Cubit<PedidosState> {
  final PedidoRepository _repository;
  final TtsService _ttsService = TtsService();
  int? _currentStoreId;

  // 🔥 ARMAZENA OS IDs DOS PEDIDOS QUE JÁ FORAM ALERTADOS
  final Set<int> _alertedPedidos = {};

  // 🔥 Manter o estado atual para fazer merge
  PedidosLoaded? _currentLoadedState;

  PedidosCubit(this._repository) : super(PedidosInitial()) {
    debugPrint('🚀 [PEDIDOS] Cubit inicializado');
    // 🔥 REGISTRA O CUBIT NO FCM PARA REFRESH AUTOMÁTICO
    FcmService().pedidoCubit = this;
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
      debugPrint('❌ [PEDIDOS] Erro ao carregar pedidos ativos: $e');
      if (!silencioso) {
        emit(PedidosError(e.toString()));
      } else if (_currentLoadedState != null) {
        emit(_currentLoadedState!.copyWith(isLoading: false));
      }
    }
  }

  /// 🔥 PROCESSAMENTO DE PEDIDOS NOVOS - USANDO syncAlerts
  void _processNovosPedidos(List<GrupoPedidos> grupos) {
    try {
      // 🔥 ENCONTRA PEDIDOS COM STATUS 'NOVO'
      final List<PedidoModel> novosItens = [];
      for (var grupo in grupos) {
        if (grupo.status == 'novo') {
          novosItens.addAll(grupo.itens);
        }
      }

      // 🔥 IDs DOS PEDIDOS QUE ESTÃO NOVOS
      final List<int> idsNovos = novosItens
          .map((p) => p.id)
          .toList();

      debugPrint('📋 [PEDIDOS] Pedidos novos encontrados: ${idsNovos.length}');

      // 🔥 CONSTRÓI A LISTA DE ALERTAS PARA OS NOVOS PEDIDOS
      final List<AlertItem> novosAlertas = [];
      for (final pedido in novosItens) {
        final alerta = PedidoUtils.formatarAlertaPedido(pedido);
        novosAlertas.add(AlertItem(pedidoId: pedido.id, text: alerta));
      }

      // 🔥 🔥 🔥 CHAMA syncAlerts - ISSO LIMPA E RECONSTRÓI A FILA
      _ttsService.syncAlerts(idsNovos, novosAlertas);

      // 🔥 ATUALIZA O SET DE ALERTADOS
      _alertedPedidos.clear();
      _alertedPedidos.addAll(idsNovos);

    } catch (e, stackTrace) {
      debugPrint('❌ [PEDIDOS] Erro ao processar pedidos novos: $e');
      debugPrint('📚 [PEDIDOS] StackTrace: $stackTrace');
    }
  }

  // 🔥 REGISTRA INTERAÇÃO DO USUÁRIO (necessário para Web)
  void registerUserInteraction() {
    debugPrint('👤 [PEDIDOS] Interação do usuário registrada para TTS');
    _ttsService.onUserInteraction();
  }

  // 🔥 CARREGAR PEDIDOS COM VERIFICAÇÃO DE LOJA
  Future<void> loadPedidosAtivosWithStoreCheck(int storeId) async {
    // Se a loja mudou, recarrega
    if (_currentStoreId != storeId) {
      debugPrint('🔄 [PEDIDOS] Loja alterada de $_currentStoreId para $storeId. Limpando alertas.');
      _currentStoreId = storeId;
      _alertedPedidos.clear();
      _ttsService.clearAlerts();
      await carregarPedidosAtivos();
    }
  }

  // 🔥 FORÇAR RECARREGAMENTO (usado quando a loja muda)
  Future<void> reloadForStoreChange() async {
    debugPrint('🔄 [PEDIDOS] Forçando recarregamento por mudança de loja');
    _currentStoreId = null; // Reseta para forçar recarregamento
    _alertedPedidos.clear();
    _ttsService.clearAlerts();
    await carregarPedidosAtivos();
  }

  // 🔥 MÉTODO PARA PROCESSAR NOVO PEDIDO (usado via socket ou push)
  Future<void> onNovoPedido(PedidoModel pedido) async {
    try {
      debugPrint('🆕 [PEDIDOS] Novo pedido recebido via Socket/Push. Recarregando lista.');
      await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
    } catch (e) {
      debugPrint('❌ [PEDIDOS] Erro ao processar novo pedido: $e');
    }
  }

  // 🔥 Refresh silencioso (background)
  Future<void> refreshSilencioso() async {
    debugPrint('🔄 [PEDIDOS] Refresh silencioso disparado');
    await carregarPedidosAtivos(silencioso: true);
  }

  // 🔥 Refresh completo (pull-to-refresh)
  Future<void> refresh() async {
    debugPrint('🔄 [PEDIDOS] Refresh manual (pull-to-refresh) disparado');
    await carregarPedidosAtivos(silencioso: false);
  }

  // 🔥 ACEITAR PEDIDO
  Future<void> aceitarPedido(int id) async {
    debugPrint('✅ [PEDIDOS] Aceitando pedido ID: $id');
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
          updatingPedidoId: null,
        );
        _currentLoadedState = novoEstado;

        emit(novoEstado);
      } else {
        await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
      }
    } catch (e) {
      debugPrint('❌ [PEDIDOS] Erro ao aceitar pedido: $e');
      if (_currentLoadedState != null) {
        emit(_currentLoadedState!.copyWith(updatingPedidoId: null));
      }
      emit(PedidoActionError(e.toString()));
    }
  }

  // 🔥 RECUSAR PEDIDO
  Future<void> recusarPedido(int id, {String? motivo, String? motivoCodigo}) async {
    debugPrint('❌ [PEDIDOS] Recusando pedido ID: $id. Motivo: $motivo');
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
          updatingPedidoId: null,
        );
        _currentLoadedState = novoEstado;

        emit(novoEstado);
      } else {
        await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
      }
    } catch (e) {
      debugPrint('❌ [PEDIDOS] Erro ao recusar pedido: $e');
      if (_currentLoadedState != null) {
        emit(_currentLoadedState!.copyWith(updatingPedidoId: null));
      }
      emit(PedidoActionError(e.toString()));
    }
  }

  // 🔥 ATUALIZAR STATUS
  Future<void> atualizarStatus(int id, String status, {String? motivo}) async {
    debugPrint('🔄 [PEDIDOS] Atualizando status pedido ID: $id para: $status');
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
          updatingPedidoId: null,
        );
        _currentLoadedState = novoEstado;
        emit(novoEstado);
      } else {
        await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
      }
    } catch (e) {
      debugPrint('❌ [PEDIDOS] Erro ao atualizar status: $e');
      if (_currentLoadedState != null) {
        emit(_currentLoadedState!.copyWith(updatingPedidoId: null));
      }
      emit(PedidoActionError(e.toString()));
    }
  }

  // 🔥 CANCELAR PEDIDO
  Future<void> cancelarPedido(int id, String motivo) async {
    debugPrint('🛑 [PEDIDOS] Cancelando pedido ID: $id. Motivo: $motivo');
    if (_currentLoadedState != null) {
      emit(_currentLoadedState!.copyWith(updatingPedidoId: id));
    }

    try {
      final response = await _repository.cancelar(id, motivo);

      // 🔥 REMOVE O ALERTA DO PEDIDO CANCELADO
      _removeAlert(id);

      if (response.grupos != null) {
        final total = response.grupos!.fold(0, (sum, group) => sum + group.total);

        // 🔥 RECALCULA ALERTAS COM A NOVA LISTA
        _processNovosPedidos(response.grupos!);

        final novoEstado = PedidosLoaded(
          grupos: response.grupos!,
          totalPedidos: total,
          isLoading: false,
          updatingPedidoId: null,
        );
        _currentLoadedState = novoEstado;
        emit(novoEstado);
      } else {
        await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
      }
    } catch (e) {
      debugPrint('❌ [PEDIDOS] Erro ao cancelar pedido: $e');
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
    debugPrint('🗑️ [PEDIDOS] Alerta removido para pedido $pedidoId');
  }

  // 🔥 ALTERNAR MUDO DO TTS
  Future<void> toggleTtsMute() async {
    final isMuted = await _ttsService.toggleMute();
    debugPrint('🔇 [PEDIDOS] TTS mudo: $isMuted');

    if (_currentLoadedState != null) {
      emit(_currentLoadedState!.copyWith());
    }
  }

  // 🔥 GETTERS
  bool get isTtsMuted => _ttsService.isMuted;
  bool get isTtsLooping => _ttsService.isLooping;
  int get pendingAlertsCount => _ttsService.pendingAlertsCount;
  List<int> get pendingPedidoIds => _ttsService.pendingPedidoIds;

  @override
  Future<void> close() {
    debugPrint('🛑 [PEDIDOS] Fechando Cubit e limpando recursos');
    _ttsService.dispose();
    return super.close();
  }
}
