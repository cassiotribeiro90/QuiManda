import 'package:flutter_tts/flutter_tts.dart';
import 'tts_interface.dart';

/// Implementação mobile do TTS usando flutter_tts
class TtsMobile implements TtsInterface {
  final FlutterTts _flutterTts = FlutterTts();
  final List<String> _queue = [];
  bool _isSpeaking = false;
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage('pt-BR');
      await _flutterTts.setSpeechRate(0.9);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _processNext();
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        print('[TTS_MOBILE] Erro: $msg');
        _processNext();
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
      });

      _isInitialized = true;
      print('[TTS_MOBILE] Inicializado com sucesso');
    } catch (e) {
      print('[TTS_MOBILE] Erro na inicialização: $e');
    }
  }

  @override
  void onUserInteraction() {
    // Mobile não precisa de gesto do usuário para TTS
  }

  @override
  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    _queue.add(text);
    print('[TTS_MOBILE] Adicionado à fila: "$text" (tamanho: ${_queue.length})');

    if (!_isSpeaking) {
      _processNext();
    }
  }

  void _processNext() async {
    if (_queue.isEmpty) {
      _isSpeaking = false;
      return;
    }

    if (_isSpeaking) return;

    final nextText = _queue.removeAt(0);
    print('[TTS_MOBILE] Falando: "$nextText" (restam ${_queue.length})');

    try {
      final result = await _flutterTts.speak(nextText);
      if (result != 1) {
        print('[TTS_MOBILE] Erro ao falar: $result');
        _isSpeaking = false;
        _processNext();
      }
    } catch (e) {
      print('[TTS_MOBILE] Exceção: $e');
      _isSpeaking = false;
      _processNext();
    }
  }

  @override
  Future<void> stopAndClear() async {
    await _flutterTts.stop();
    _queue.clear();
    _isSpeaking = false;
    print('[TTS_MOBILE] Parado e fila limpa');
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  int get queueLength => _queue.length;

  @override
  void dispose() {
    _flutterTts.stop();
    _queue.clear();
  }
}
