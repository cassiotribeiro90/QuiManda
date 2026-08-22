import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'tts_interface.dart';
import 'tts_factory.dart';
import 'tts_config_service.dart';

/// Serviço TTS - Loop simples com fila de pedidos
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  TtsInterface? _impl;
  bool _isMuted = false;
  bool _isInitialized = false;
  bool _isUserInteracted = false;

  List<int> _pendingIds = [];
  Map<int, String> _alerts = {};
  int _currentIndex = 0;
  bool _isLooping = false;
  Timer? _loopTimer;
  bool _isSpeaking = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final config = GetIt.I<TtsConfigService>();
      _isMuted = !config.isTtsEnabled();
    } catch (_) {}

    try {
      _impl = TtsFactory.create();
      await _impl!.init();
      _isInitialized = true;
      print('[TTS] ✅ OK, mudo: $_isMuted');
    } catch (e) {
      print('[TTS] ❌ Erro: $e');
    }
  }

  void onUserInteraction() {
    _isUserInteracted = true;
    _impl?.onUserInteraction();
  }

  /// 🔥 Substitui toda a fila pelos pedidos novos
  void syncAlerts(List<int> novosIds, List<AlertItem> novosAlertas) {
    _pendingIds.clear();
    _alerts.clear();
    for (final item in novosAlertas) {
      if (!_alerts.containsKey(item.pedidoId)) {
        _pendingIds.add(item.pedidoId);
        _alerts[item.pedidoId] = item.text;
      }
    }
    _currentIndex = 0;
    if (_pendingIds.isEmpty) {
      _stopAll();
      return;
    }
    if (!_isLooping && !_isMuted) _startLoop();
  }

  /// 🔥 Remove um pedido específico
  void removeAlertByPedidoId(int pedidoId) {
    final idx = _pendingIds.indexOf(pedidoId);
    if (idx == -1) return;
    _pendingIds.removeAt(idx);
    _alerts.remove(pedidoId);
    if (_pendingIds.isEmpty) {
      _stopAll();
    } else if (_currentIndex >= _pendingIds.length) {
      _currentIndex = 0;
    }
  }

  /// 🔥 Fala um texto avulso (sem pedido)
  Future<void> speakText(String text) async {
    if (text.isEmpty || _isMuted) return;

    // Se não está falando e não tem fila, fala diretamente
    if (!_isSpeaking && _pendingIds.isEmpty) {
      _isSpeaking = true;
      try {
        await _impl!.speak(text);
      } catch (_) {
        // Ignora erro
      } finally {
        _isSpeaking = false;
      }
      return;
    }

    // Se está ocupado, adiciona como alerta temporário (ID 0)
    _pendingIds.add(0);
    _alerts[0] = text;
    if (!_isLooping) _startLoop();
  }

  void clearAlerts() {
    _pendingIds.clear();
    _alerts.clear();
    _currentIndex = 0;
    _stopAll();
  }

  // ════════════════════════════════════════════════
  //  LOOP PRINCIPAL
  // ════════════════════════════════════════════════

  void _startLoop() {
    if (_isLooping || _isMuted || _pendingIds.isEmpty) return;
    _isLooping = true;
    _processLoop();
  }

  void _processLoop() {
    if (_pendingIds.isEmpty || _isMuted) { _stopAll(); return; }
    if (_isSpeaking) return;
    if (_currentIndex >= _pendingIds.length) _currentIndex = 0;

    final id = _pendingIds[_currentIndex];
    final text = _alerts[id];
    if (text == null || text.isEmpty) {
      _pendingIds.removeAt(_currentIndex);
      _alerts.remove(id);
      _processLoop();
      return;
    }

    _isSpeaking = true;
    _impl!.speak(text).then((_) {
      _isSpeaking = false;
      _currentIndex = (_currentIndex + 1) % _pendingIds.length;
      _loopTimer = Timer(const Duration(seconds: 2), () {
        if (_pendingIds.isNotEmpty && !_isMuted) {
          if (kIsWeb) onUserInteraction();
          _processLoop();
        } else _stopAll();
      });
    }).catchError((_) {
      _isSpeaking = false;
      _currentIndex = (_currentIndex + 1) % _pendingIds.length;
      _loopTimer = Timer(const Duration(seconds: 2), () => _processLoop());
    });
  }

  void _stopAll() {
    _isLooping = false;
    _loopTimer?.cancel();
    _loopTimer = null;
    if (_isSpeaking) { _impl?.stopAndClear(); _isSpeaking = false; }
  }

  // ════════════════════════════════════════════════
  //  CONTROLES EXTERNOS
  // ════════════════════════════════════════════════

  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    try { await GetIt.I<TtsConfigService>().setTtsEnabled(!muted); } catch (_) {}
    if (muted) _stopAll();
    else if (_pendingIds.isNotEmpty) _startLoop();
  }

  Future<bool> toggleMute() async { await setMuted(!_isMuted); return _isMuted; }

  bool get isLooping => _isLooping;
  int get pendingAlertsCount => _pendingIds.length;
  bool get isMuted => _isMuted;
  bool get isSpeaking => _isSpeaking;
  List<int> get pendingPedidoIds => List.from(_pendingIds);

  void dispose() { _stopAll(); _pendingIds.clear(); _alerts.clear(); _impl?.dispose(); }
}

/// Item para compatibilidade
class AlertItem {
  final int pedidoId;
  final String text;
  AlertItem({required this.pedidoId, required this.text});
}