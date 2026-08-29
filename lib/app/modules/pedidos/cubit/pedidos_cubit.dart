import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/fcm_service.dart';
import 'pedidos_state.dart';
import '../repository/pedidos_repository.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/utils/pedido_utils.dart';
import '../model/pedido_model.dart';
import '../../../models/chat_nao_lido.dart';

class PedidosCubit extends Cubit<PedidosState> {
  final PedidoRepository _repository;
  final TtsService _ttsService = TtsService();
  int? _currentStoreId;

  // 🔥 CONTROLE DE TTS EM LOOP
  final Set<int> _spokenChatIds = {};
  final Set<int> _spokenPedidoNewIds = {};
  final Set<int> _spokenPedidoMsgIds = {};
  
  // 🔥 RASTREIO DE CONTADORES PARA FORÇAR FALA EM CASO DE AUMENTO
  final Map<int, int> _lastChatCounts = {};
  final Map<int, int> _lastPedidoCounts = {};
  
  bool _isFirstLoad = true;
  Timer? _ttsLoopTimer;

  // 🔥 Manter o estado atual para fazer merge
  PedidosLoaded? _currentLoadedState;

  PedidosCubit(this._repository) : super(PedidosInitial()) {
    debugPrint('🚀 [PEDIDOS] Cubit inicializado');
    // 🔥 REGISTRA O CUBIT NO FCM PARA REFRESH AUTOMÁTICO
    FcmService().pedidoCubit = this;
    
    // Inicializa o TTS e inicia o loop contínuo
    _ttsService.init().then((_) {
      _startTtsLoop();
    });
  }

  // 🔥 LOOP CONTÍNUO DO TTS
  void _startTtsLoop() {
    _ttsLoopTimer?.cancel();
    _ttsLoopTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (state is PedidosLoaded && !isClosed) {
        final currentState = state as PedidosLoaded;
        if (!currentState.isTtsMuted && currentState.pendingAlertsCount > 0) {
          _processTtsQueue(currentState);
        }
      }
    });
  }

  // 🔥 PROCESSAR A FILA DE TTS
  void _processTtsQueue(PedidosLoaded state) {
    if (_ttsService.isSpeaking) return;

    // Log para depuração
    for (var p in state.pedidosComNaoLidas) {
       debugPrint('🔎 [TTS_CHECK] Pedido #${p.id} status=${p.status} naoLidas=${p.naoLidas}');
    }

    // 1. Primeiro, fala os chats genéricos não lidos
    for (var chat in state.chatsNaoLidos) {
      if (!_spokenChatIds.contains(chat.chatId)) {
        debugPrint('🔊 [TTS] Falando Chat: ${chat.clienteNome}');
        _ttsService.speakText('Nova mensagem de ${chat.clienteNome}');
        _spokenChatIds.add(chat.chatId);
        return; // Fala um por vez
      }
    }

    // 2. Depois, fala as MENSAGENS dentro de pedidos
    for (var pedido in state.pedidosComNaoLidas) {
      if (pedido.naoLidas > 0 && !_spokenPedidoMsgIds.contains(pedido.id)) {
        debugPrint('🔊 [TTS] Falando Mensagem no Pedido #${pedido.id}: ${pedido.clienteNome}');
        _ttsService.speakText('Nova mensagem de ${pedido.clienteNome}, sobre um pedido');
        _spokenPedidoMsgIds.add(pedido.id);
        return; // Fala um por vez
      }
    }

    // 3. Por fim, fala os NOVOS pedidos
    for (var pedido in state.pedidosComNaoLidas) {
      if (pedido.status == 'novo' && !_spokenPedidoNewIds.contains(pedido.id)) {
        debugPrint('🔊 [TTS] Falando Novo Pedido #${pedido.id}: ${pedido.clienteNome}');
        _ttsService.speakText('Novo pedido de ${pedido.clienteNome}');
        _spokenPedidoNewIds.add(pedido.id);
        return; // Fala um por vez
      }
    }

    // 4. Se todos os tipos de alerta já foram falados, reseta para repetir após um delay
    final Set<String> alertasAtivos = {};
    for (var c in state.chatsNaoLidos) {
      alertasAtivos.add('chat_${c.chatId}');
    }
    for (var p in state.pedidosComNaoLidas) {
      if (p.naoLidas > 0) alertasAtivos.add('msg_${p.id}');
      if (p.status == 'novo') alertasAtivos.add('new_${p.id}');
    }

    final Set<String> alertasFalados = {};
    for (var id in _spokenChatIds) {
      alertasFalados.add('chat_$id');
    }
    for (var id in _spokenPedidoMsgIds) {
      alertasFalados.add('msg_$id');
    }
    for (var id in _spokenPedidoNewIds) {
      alertasFalados.add('new_$id');
    }

    // Verifica se todos os alertas ativos já estão no set de falados
    bool todosFalados = alertasAtivos.every((a) => alertasFalados.contains(a));

    if (todosFalados && alertasAtivos.isNotEmpty) {
      debugPrint('🔁 [TTS] Ciclo concluído (${alertasAtivos.length} alertas). Reiniciando em 5 segundos...');
      Future.delayed(const Duration(seconds: 5), () {
        if (!isClosed) {
          _resetSpokenIds();
        }
      });
    }
  }

  void _resetSpokenIds() {
    _spokenChatIds.clear();
    _spokenPedidoNewIds.clear();
    _spokenPedidoMsgIds.clear();
  }

  /// 🔥 DETECTA AUMENTO NO NÚMERO DE MENSAGENS PARA FORÇAR A FALA NOVAMENTE
  void _checkCountIncreases(List<ChatNaoLido> chats, List<PedidoModel> pedidos) {
    // Verifica chats genéricos
    for (var chat in chats) {
      final lastCount = _lastChatCounts[chat.chatId] ?? 0;
      if (chat.naoLidas > lastCount) {
        debugPrint('🔔 [TTS] Aumento de mensagens no Chat #${chat.chatId}. Forçando fala.');
        _spokenChatIds.remove(chat.chatId);
      }
      _lastChatCounts[chat.chatId] = chat.naoLidas;
    }

    // Verifica mensagens em pedidos
    for (var pedido in pedidos) {
      final lastCount = _lastPedidoCounts[pedido.id] ?? 0;
      if (pedido.naoLidas > lastCount) {
        debugPrint('🔔 [TTS] Aumento de mensagens no Pedido #${pedido.id}. Forçando fala.');
        _spokenPedidoMsgIds.remove(pedido.id);
      }
      _lastPedidoCounts[pedido.id] = pedido.naoLidas;
    }

    // Limpa rastreio de itens que saíram da lista
    final currentChatIds = chats.map((c) => c.chatId).toSet();
    _lastChatCounts.removeWhere((id, _) => !currentChatIds.contains(id));
    
    final currentPedidoIds = pedidos.map((p) => p.id).toSet();
    _lastPedidoCounts.removeWhere((id, _) => !currentPedidoIds.contains(id));
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

      // 🔥 IDENTIFICA ITENS PARA TTS
      final allPedidos = groupedModels.expand((g) => g.itens).toList();
      
      // Filtra pedidos que precisam de alerta: Status 'novo' OU mensagens não lidas
      final pedidosComNaoLidas = allPedidos.where((p) {
        return p.naoLidas > 0 || p.status == 'novo';
      }).toList();
      
      final chatsNaoLidos = (data['chats_nao_lidos'] as List?)
              ?.map((c) => ChatNaoLido.fromJson(c))
              .toList() ??
          [];

      // 🔥 DETECTA AUMENTO DE MENSAGENS PARA FORÇAR RE-FALA IMEDIATA
      _checkCountIncreases(chatsNaoLidos, allPedidos);

      // 🔥 SE É A PRIMEIRA CARGA, GARANTE QUE VAI FALAR TUDO
      if (_isFirstLoad && (pedidosComNaoLidas.isNotEmpty || chatsNaoLidos.isNotEmpty)) {
        _resetSpokenIds();
        _isFirstLoad = false;
      }

      // 🔥 CALCULA TOTAL DE ALERTAS ÚNICOS (Chat + Msg Pedido + Novo Pedido)
      final Set<String> alertasUnicos = {};
      for (var c in chatsNaoLidos) {
        alertasUnicos.add('chat_${c.chatId}');
      }
      for (var p in pedidosComNaoLidas) {
        if (p.naoLidas > 0) alertasUnicos.add('msg_${p.id}');
        if (p.status == 'novo') alertasUnicos.add('new_${p.id}');
      }

      final novoEstado = PedidosLoaded(
        grupos: List<GrupoPedidos>.from(groupedModels),
        totalPedidos: total,
        chatsNaoLidos: chatsNaoLidos,
        pedidosComNaoLidas: pedidosComNaoLidas,
        pendingAlertsCount: alertasUnicos.length,
        isTtsMuted: _ttsService.isMuted,
        isTtsLooping: true,
        isLoading: false,
      );

      _currentLoadedState = novoEstado;
      emit(novoEstado);
      
      // Inicia processamento imediato se houver algo
      if (!novoEstado.isTtsMuted && novoEstado.pendingAlertsCount > 0) {
        _processTtsQueue(novoEstado);
      }
      
    } catch (e) {
      debugPrint('❌ [PEDIDOS] Erro ao carregar pedidos ativos: $e');
      if (!silencioso) {
        emit(PedidosError(e.toString()));
      } else if (_currentLoadedState != null) {
        emit(_currentLoadedState!.copyWith(isLoading: false));
      }
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
      _resetSpokenIds();
      _ttsService.clearAlerts();
      await carregarPedidosAtivos();
    }
  }

  // 🔥 FORÇAR RECARREGAMENTO (usado quando a loja muda)
  Future<void> reloadForStoreChange() async {
    debugPrint('🔄 [PEDIDOS] Forçando recarregamento por mudança de loja');
    _currentStoreId = null; // Reseta para forçar recarregamento
    _resetSpokenIds();
    _ttsService.clearAlerts();
    await carregarPedidosAtivos();
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
      await _repository.aceitar(id);
      
      // Remove do rastreio de TTS e força recarga
      _spokenPedidoNewIds.remove(id);
      _spokenPedidoMsgIds.remove(id);
      await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
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
      await _repository.recusar(id, motivo: motivo, motivoCodigo: motivoCodigo);
      
      // Remove do rastreio de TTS e força recarga
      _spokenPedidoNewIds.remove(id);
      _spokenPedidoMsgIds.remove(id);
      await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
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
      await _repository.atualizarStatus(id, status, motivo: motivo);
      await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
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
      await _repository.cancelar(id, motivo);
      
      // Remove do rastreio de TTS e força recarga
      _spokenPedidoNewIds.remove(id);
      _spokenPedidoMsgIds.remove(id);
      await carregarPedidosAtivos(silencioso: true, forceRefresh: true);
    } catch (e) {
      debugPrint('❌ [PEDIDOS] Erro ao cancelar pedido: $e');
      if (_currentLoadedState != null) {
        emit(_currentLoadedState!.copyWith(updatingPedidoId: null));
      }
      emit(PedidoActionError(e.toString()));
    }
  }

  // 🔥 ALTERNAR MUDO DO TTS
  Future<void> toggleTtsMute() async {
    final isMuted = await _ttsService.toggleMute();
    debugPrint('🔇 [PEDIDOS] TTS mudo: $isMuted');

    if (!isMuted) {
      // 🔥 Ao ativar o som, reseta os IDs para repetir tudo imediatamente
      _resetSpokenIds();
      debugPrint('🔊 [TTS] Som ativado. Reiniciando fila de alertas.');
    }

    if (_currentLoadedState != null) {
      final novoEstado = _currentLoadedState!.copyWith(isTtsMuted: isMuted);
      _currentLoadedState = novoEstado;
      emit(novoEstado);
      
      if (!isMuted && novoEstado.pendingAlertsCount > 0) {
        _processTtsQueue(novoEstado);
      }
    }
  }

  // 🔥 GETTERS
  bool get isTtsMuted => _ttsService.isMuted;
  bool get isTtsLooping => _currentLoadedState?.isTtsLooping ?? false;
  int get pendingAlertsCount => _currentLoadedState?.pendingAlertsCount ?? 0;

  @override
  Future<void> close() {
    debugPrint('🛑 [PEDIDOS] Fechando Cubit e limpando recursos');
    _ttsLoopTimer?.cancel();
    _ttsService.dispose();
    return super.close();
  }
}
