import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'tts_interface.dart';
import 'tts_factory.dart';
import 'tts_config_service.dart';
import 'tts_web.dart';

/// Item da fila de alertas com ID do pedido para filtragem
class _AlertItem {
  final int pedidoId;
  final String text;

  _AlertItem({required this.pedidoId, required this.text});
}

/// Serviço unificado de TTS com loop e intervalo
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  TtsInterface? _impl;
  bool _isMuted = false;
  bool _isInitialized = false;
  bool _isUserInteracted = false;
  
  // 🔥 FILA DE ALERTAS COM ID DO PEDIDO
  final List<_AlertItem> _pendingAlerts = [];
  bool _isLooping = false;
  Timer? _loopTimer;
  bool _isSpeaking = false;
  String? _currentAlertText;

  /// Inicializa o TTS
  Future<void> init() async {
    if (_isInitialized) return;

    // Carrega configuração de mudo
    try {
      final configService = GetIt.I<TtsConfigService>();
      _isMuted = !configService.isTtsEnabled();
    } catch (_) {
      _isMuted = false;
    }

    _impl = TtsFactory.create();
    await _impl!.init();
    _isInitialized = true;
    print('[TTS_SERVICE] Inicializado, mudo: $_isMuted');
  }

  /// 🔥 MARCA INTERAÇÃO DO USUÁRIO
  void onUserInteraction() {
    _isUserInteracted = true;
    print('[TTS_SERVICE] Interação do usuário registrada');
    
    // Propaga para a implementação (especialmente WEB)
    _impl?.onUserInteraction();
  }

  /// 🔥 ADICIONA UM ALERTA COM ID DO PEDIDO
  void addAlert(int pedidoId, String text) {
    try {
      if (text.isEmpty) return;
      if (isMuted) return;
      
      // 🔥 VERIFICA SE O ID É VÁLIDO
      // ignore: unnecessary_null_comparison
      if (pedidoId == null || pedidoId <= 0) {
        print('[TTS_SERVICE] ⚠️ ID inválido: $pedidoId');
        return;
      }
      
      // 🔥 VERIFICA SE JÁ EXISTE ALERTA PARA ESTE PEDIDO
      final exists = _pendingAlerts.any((item) => item.pedidoId == pedidoId);
      if (exists) {
        print('[TTS_SERVICE] Alerta já existe para pedido $pedidoId');
        return;
      }

      _pendingAlerts.add(_AlertItem(pedidoId: pedidoId, text: text));
      print('[TTS_SERVICE] 🔔 Alerta adicionado: pedido $pedidoId (total: ${_pendingAlerts.length})');
      
      // 🔥 REGISTRA INTERAÇÃO (WEB) ANTES DE FALAR
      if (!_isUserInteracted && kIsWeb) {
        onUserInteraction();
      }
      
      if (!_isLooping && !_isMuted && (_isUserInteracted || !kIsWeb)) {
        _startLoop();
      }
    } catch (e) {
      print('[TTS_SERVICE] ❌ Erro ao adicionar alerta: $e');
    }
  }

  /// 🔥 REMOVE ALERTA POR ID DO PEDIDO
  void removeAlertByPedidoId(int pedidoId) {
    try {
      final lengthBefore = _pendingAlerts.length;
      _pendingAlerts.removeWhere((item) => item != null && item.pedidoId == pedidoId);
      
      if (_pendingAlerts.length < lengthBefore) {
        print('[TTS_SERVICE] ❌ Alerta removido para pedido $pedidoId (restam: ${_pendingAlerts.length})');
      }
      
      // Se o alerta removido era o único, para a fala atual se estiver ativa
      if (_pendingAlerts.isEmpty) {
        _stopSpeaking();
        _stopLoop();
      }
    } catch (e) {
      print('[TTS_SERVICE] ❌ Erro ao remover alerta: $e');
    }
  }

  /// 🔥 REMOVE TODOS OS ALERTAS EXCETO OS DE PEDIDOS QUE AINDA SÃO NOVOS
  void filterAlerts(List<int> novosPedidosIds) {
    try {
      // 🔥 VERIFICA SE A LISTA É VÁLIDA
      // ignore: unnecessary_null_comparison
      final idsNovos = novosPedidosIds ?? [];
      
      if (idsNovos.isEmpty) {
        // Se não tem pedidos novos, remove todos os alertas
        if (_pendingAlerts.isNotEmpty) {
          print('[TTS_SERVICE] 🧹 Removendo todos os alertas (sem pedidos novos)');
          _pendingAlerts.clear();
          _stopLoop();
          _stopSpeaking();
        }
        return;
      }

      // 🔥 CONVERTE PARA Set PARA BUSCA MAIS RÁPIDA
      final idsNovosSet = idsNovos.toSet();
      
      final antes = _pendingAlerts.length;
      
      // MANTÉM APENAS OS ALERTAS QUE ESTÃO NA LISTA DE NOVOS
      _pendingAlerts.removeWhere((item) {
        if (item == null) return true;
        return !idsNovosSet.contains(item.pedidoId);
      });
      
      final removidos = antes - _pendingAlerts.length;
      if (removidos > 0) {
        print('[TTS_SERVICE] 🧹 Filtrados $removidos alertas (restam: ${_pendingAlerts.length})');
      }
      
      // Se não tem mais alertas, para o loop e a fala
      if (_pendingAlerts.isEmpty) {
        _stopSpeaking();
        _stopLoop();
      } else if (_currentAlertText != null) {
        // Se o alerta que está sendo falado agora foi removido, interrompe
        final currentExists = _pendingAlerts.any((item) => item != null && item.text == _currentAlertText);
        if (!currentExists) {
          _stopSpeaking();
          // O loop continuará com o próximo disponível
          if (!_isMuted) _processLoop();
        }
      }
    } catch (e) {
      print('[TTS_SERVICE] ❌ Erro ao filtrar alertas: $e');
    }
  }

  void _startLoop() {
    if (_isLooping) return;
    if (_isMuted) return;
    if (_pendingAlerts.isEmpty) return;

    _isLooping = true;
    print('[TTS_SERVICE] 🔄 Loop iniciado');
    
    // 🔥 PEQUENO DELAY PARA GARANTIR QUE O CONTEXTO ESTÁ ATIVO
    Future.delayed(const Duration(milliseconds: 300), _processLoop);
  }

  void _processLoop() {
    if (_pendingAlerts.isEmpty || _isMuted) {
      _stopLoop();
      return;
    }

    if (_isSpeaking) {
      return;
    }

    // 🔥 PEGA O PRIMEIRO ALERTA DA FILA
    final alertItem = _pendingAlerts.first;
    _currentAlertText = alertItem.text;
    _isSpeaking = true;
    
    print('[TTS_SERVICE] 🔊 Falando: "${alertItem.text}"');
    
    _impl!.speak(alertItem.text).then((_) {
      _isSpeaking = false;
      _currentAlertText = null;
      
      // 🔥 ROTACIONA A FILA (coloca o que acabou de falar no fim para repetir depois de todos os outros)
      if (_pendingAlerts.isNotEmpty && _pendingAlerts.first == alertItem) {
        final first = _pendingAlerts.removeAt(0);
        _pendingAlerts.add(first);
      }
      
      print('[TTS_SERVICE] ⏳ Aguardando 4 segundos...');
      
      // 🔥 AGUARDA 4 SEGUNDOS
      _loopTimer?.cancel();
      _loopTimer = Timer(const Duration(seconds: 4), () {
        // 🔥 VERIFICA SE TEM MAIS ALERTAS
        if (_pendingAlerts.isNotEmpty && !_isMuted) {
          // 🔥 REATIVA O CONTEXTO ANTES DE CONTINUAR (WEB)
          if (kIsWeb) {
            onUserInteraction();
          }
          _processLoop();
        } else {
          _stopLoop();
        }
      });
    }).catchError((e) {
      print('[TTS_SERVICE] ❌ Erro ao falar: $e');
      _isSpeaking = false;
      _currentAlertText = null;
      
      // Rotaciona mesmo em erro para não travar no mesmo
      if (_pendingAlerts.isNotEmpty && _pendingAlerts.first == alertItem) {
        final first = _pendingAlerts.removeAt(0);
        _pendingAlerts.add(first);
      }

      // 🔥 TENTA RECUPERAR
      if (kIsWeb) {
        onUserInteraction();
      }
      _loopTimer?.cancel();
      _loopTimer = Timer(const Duration(seconds: 2), _processLoop);
    });
  }

  void _stopLoop() {
    _isLooping = false;
    _loopTimer?.cancel();
    _loopTimer = null;
    print('[TTS_SERVICE] ⏹️ Loop parado');
  }

  void _stopSpeaking() {
    if (_isSpeaking) {
      _impl?.stopAndClear();
      _isSpeaking = false;
      _currentAlertText = null;
      print('[TTS_SERVICE] Fala interrompida');
    }
  }

  void removeAlert(String text) {
    _pendingAlerts.removeWhere((item) => item != null && item.text == text);
    print('[TTS_SERVICE] Alerta removido: "$text" (restam: ${_pendingAlerts.length})');
    if (_pendingAlerts.isEmpty) {
      _stopSpeaking();
      _stopLoop();
    }
  }

  void clearAlerts() {
    _pendingAlerts.clear();
    _stopSpeaking();
    _stopLoop();
    print('[TTS_SERVICE] Todos os alertas limpos');
  }

  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    try {
      final configService = GetIt.I<TtsConfigService>();
      await configService.setTtsEnabled(!muted);
    } catch (_) {}
    
    print('[TTS_SERVICE] Mudo: $_isMuted');

    if (_isMuted) {
      _stopSpeaking();
      _stopLoop();
    } else if (_pendingAlerts.isNotEmpty) {
      // 🔥 REATIVA O CONTEXTO (WEB)
      if (kIsWeb) {
        onUserInteraction();
      }
      _startLoop();
    }
  }

  Future<bool> toggleMute() async {
    final newMuted = !_isMuted;
    await setMuted(newMuted);
    return _isMuted;
  }

  bool get isLooping => _isLooping;
  int get pendingAlertsCount => _pendingAlerts.length;
  bool get isMuted => _isMuted;
  bool get isSpeaking => _isSpeaking;

  Future<void> stopAndClear() async {
    _stopSpeaking();
    _stopLoop();
    _pendingAlerts.clear();
    await _impl?.stopAndClear();
  }

  void dispose() {
    _stopSpeaking();
    _stopLoop();
    _pendingAlerts.clear();
    _impl?.dispose();
  }
}
