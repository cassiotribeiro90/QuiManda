import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'tts_interface.dart';
import 'tts_factory.dart';
import 'tts_config_service.dart';

/// Serviço unificado de TTS - Simplificado
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  TtsInterface? _impl;
  bool _isMuted = false;
  bool _isInitialized = false;
  bool _isUserInteracted = false;

  // 🔥 ESTRUTURA SIMPLES9
  List<int> _pendingIds = [];
  Map<int, String> _alerts = {};
  int _currentIndex = 0;
  bool _isLooping = false;
  Timer? _loopTimer;
  bool _isSpeaking = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final configService = GetIt.I<TtsConfigService>();
      _isMuted = !configService.isTtsEnabled();
    } catch (_) {
      _isMuted = false;
    }

    try {
      _impl = TtsFactory.create();
      await _impl!.init();
      _isInitialized = true;
      print('[TTS_SERVICE] ✅ Inicializado, mudo: $_isMuted');
    } catch (e) {
      print('[TTS_SERVICE] ❌ Erro ao inicializar: $e');
    }
  }

  void onUserInteraction() {
    _isUserInteracted = true;
    _impl?.onUserInteraction();
  }

  /// 🔥 SYNCHRONIZE - SUBSTITUI A LISTA INTEIRA
  void syncAlerts(List<int> novosIds, List<AlertItem> novosAlertas) {
    try {
      print('[TTS_SERVICE] 📋 Sincronizando: ${novosIds.length} pedidos');

      // 🔥 CRIA A NOVA LISTA (GARANTE QUE NÃO TEM DUPLICATAS)
      final novosIdsUnicos = novosIds.toSet().toList();
      final novaLista = <int>[];
      final novoMap = <int, String>{};

      for (final item in novosAlertas) {
        if (!novoMap.containsKey(item.pedidoId)) {
          novaLista.add(item.pedidoId);
          novoMap[item.pedidoId] = item.text;
        }
      }

      // 🔥 🔥 🔥 SUBSTITUI A LISTA INTEIRA
      _pendingIds = novaLista;
      _alerts = novoMap;

      // 🔥 🔥 🔥 AJUSTA O ÍNDICE
      if (_pendingIds.isEmpty) {
        _currentIndex = 0;
        _stopLoop();
        _stopSpeaking();
        print('[TTS_SERVICE] 🔇 Sem pedidos, loop parado');
        return;
      }

      if (_currentIndex >= _pendingIds.length) {
        _currentIndex = _pendingIds.length - 1;
      }

      print('[TTS_SERVICE] 📋 IDs: ${_pendingIds.join(", ")}');
      print('[TTS_SERVICE] 📋 Índice: $_currentIndex');

      // 🔥 REINICIA O LOOP
      if (!_isLooping && !_isMuted) {
        _startLoop();
      }
    } catch (e) {
      print('[TTS_SERVICE] ❌ Erro ao sincronizar: $e');
    }
  }

  /// 🔥 REMOVE UM PEDIDO DA LISTA
  void removeAlertByPedidoId(int pedidoId) {
    final index = _pendingIds.indexOf(pedidoId);
    if (index == -1) {
      print('[TTS_SERVICE] ⚠️ Pedido $pedidoId não encontrado');
      return;
    }

    print('[TTS_SERVICE] ❌ Removendo pedido $pedidoId');

    _pendingIds.removeAt(index);
    _alerts.remove(pedidoId);

    // 🔥 AJUSTA O ÍNDICE
    if (_pendingIds.isEmpty) {
      _currentIndex = 0;
      _stopLoop();
      _stopSpeaking();
      print('[TTS_SERVICE] 🔇 Último pedido removido, loop parado');
    } else if (_currentIndex >= _pendingIds.length) {
      _currentIndex = _pendingIds.length - 1;
    }
  }

  void clearAlerts() {
    print('[TTS_SERVICE] 🧹 Limpando tudo');
    _pendingIds = [];
    _alerts = {};
    _currentIndex = 0;
    _stopLoop();
    _stopSpeaking();
  }

  // ==================== MÉTODOS INTERNOS ====================

  void _startLoop() {
    if (_isLooping) return;
    if (_isMuted) return;
    if (_pendingIds.isEmpty) return;

    _isLooping = true;
    print('[TTS_SERVICE] 🔄 Loop iniciado (${_pendingIds.length} pedidos)');
    _processLoop();
  }

  void _processLoop() {
    if (_pendingIds.isEmpty || _isMuted) {
      _stopLoop();
      return;
    }

    if (_isSpeaking) return;

    // 🔥 GARANTE ÍNDICE VÁLIDO
    if (_currentIndex >= _pendingIds.length) {
      _currentIndex = _pendingIds.length - 1;
    }
    if (_currentIndex < 0) {
      _currentIndex = 0;
    }

    final pedidoId = _pendingIds[_currentIndex];
    final text = _alerts[pedidoId];

    if (text == null || text.isEmpty) {
      _pendingIds.removeAt(_currentIndex);
      _alerts.remove(pedidoId);
      if (_pendingIds.isEmpty) {
        _stopLoop();
        return;
      }
      if (_currentIndex >= _pendingIds.length) {
        _currentIndex = _pendingIds.length - 1;
      }
      _processLoop();
      return;
    }

    // 🔥 FALA
    _isSpeaking = true;
    print('[TTS_SERVICE] 🔊 Falando pedido $pedidoId: "$text"');

    _impl!
        .speak(text)
        .then((_) {
      _isSpeaking = false;
      print('[TTS_SERVICE] ✅ Terminou pedido $pedidoId');

      // 🔥 AVANÇA ÍNDICE
      _currentIndex++;
      if (_currentIndex >= _pendingIds.length) {
        _currentIndex = 0;
      }

      print('[TTS_SERVICE] ⏳ Próximo índice: $_currentIndex');

      // 🔥 DELAY DE 4 SEGUNDOS APÓS A FALA
      _loopTimer?.cancel();
      _loopTimer = Timer(const Duration(seconds: 2), () {
        if (_pendingIds.isNotEmpty && !_isMuted) {
          if (kIsWeb) onUserInteraction();
          _processLoop();
        } else {
          _stopLoop();
        }
      });
    })
        .catchError((e) {
      print('[TTS_SERVICE] ❌ Erro: $e');
      _isSpeaking = false;
      _currentIndex++;
      if (_currentIndex >= _pendingIds.length) {
        _currentIndex = 0;
      }
      _loopTimer?.cancel();
      _loopTimer = Timer(const Duration(seconds: 2), () {
        if (_pendingIds.isNotEmpty) {
          _processLoop();
        } else {
          _stopLoop();
        }
      });
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
      print('[TTS_SERVICE] 🛑 Fala interrompida');
    }
  }

  // ==================== MÉTODOS DESATIVADOS ====================

  void addAlert(int pedidoId, String text) {
    print('[TTS_SERVICE] ⚠️ addAlert DESATIVADO');
  }

  void filterAlerts(List<int> ids) {
    print('[TTS_SERVICE] ⚠️ filterAlerts DESATIVADO');
  }

  void removeAlert(String text) {
    print('[TTS_SERVICE] ⚠️ removeAlert DESATIVADO');
  }

  // ==================== GETTERS ====================

  bool get isLooping => _isLooping;
  int get pendingAlertsCount => _pendingIds.length;
  bool get isMuted => _isMuted;
  bool get isSpeaking => _isSpeaking;
  List<int> get pendingPedidoIds => List.from(_pendingIds);

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
    } else if (_pendingIds.isNotEmpty) {
      if (kIsWeb) onUserInteraction();
      _startLoop();
    }
  }

  Future<bool> toggleMute() async {
    final newMuted = !_isMuted;
    await setMuted(newMuted);
    return _isMuted;
  }

  Future<void> stopAndClear() async {
    _stopSpeaking();
    _stopLoop();
    _pendingIds = [];
    _alerts = {};
    _currentIndex = 0;
    await _impl?.stopAndClear();
  }

  void dispose() {
    _stopSpeaking();
    _stopLoop();
    _pendingIds = [];
    _alerts = {};
    _impl?.dispose();
  }
}

/// Item para compatibilidade
class AlertItem {
  final int pedidoId;
  final String text;

  AlertItem({required this.pedidoId, required this.text});
}