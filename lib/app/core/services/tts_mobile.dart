import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'tts_interface.dart';

/// Implementação mobile do TTS usando flutter_tts
class TtsMobile implements TtsInterface {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isInitialized = false;

  // 🔥 SEM FILA INTERNA - O TtsService gerencia a fila

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage('pt-BR');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        debugPrint('🔊 [TTS_MOBILE] 🎤 Iniciou fala');
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        debugPrint('✅ [TTS_MOBILE] ✅ Fala finalizada');
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        debugPrint('❌ [TTS_MOBILE] ❌ Erro: $msg');
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        debugPrint('🛑 [TTS_MOBILE] 🛑 Fala cancelada');
      });

      _isInitialized = true;
      debugPrint('🚀 [TTS_MOBILE] ✅ Inicializado com sucesso');
    } catch (e) {
      debugPrint('❌ [TTS_MOBILE] ❌ Erro na inicialização: $e');
    }
  }

  @override
  void onUserInteraction() {
    // Mobile não precisa de gesto do usuário para TTS
  }

  /// 🔥 LIMPA TEXTO - REMOVE EMOJIS E CARACTERES ESPECIAIS
  String _cleanText(String text) {
    String cleaned = text.replaceAll(RegExp(r'[^\w\s,.!?\-]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.trim();
    return cleaned.isEmpty ? 'Pedido' : cleaned;
  }

  @override
  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    final cleanText = _cleanText(text);
    if (cleanText.isEmpty) return;

    if (_isSpeaking) {
      debugPrint('⚠️ [TTS_MOBILE] ⚠️ Já está falando, ignorando: "$cleanText"');
      return;
    }

    debugPrint('🔊 [TTS_MOBILE] 🔊 Falando: "$cleanText"');

    try {
      // 🔥 CRIA UM COMPLETER PARA AGUARDAR O FIM DA FALA
      final completer = Completer<void>();

      // 🔥 SALVA OS HANDLERS ORIGINAIS
      final originalCompletion = _flutterTts.completionHandler;
      final originalError = _flutterTts.errorHandler;

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        debugPrint('✅ [TTS_MOBILE] ✅ Fala finalizada');
        if (!completer.isCompleted) {
          completer.complete();
        }
        // 🔥 RESTAURA O HANDLER ORIGINAL
        if (originalCompletion != null) {
          _flutterTts.setCompletionHandler(originalCompletion);
        }
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        debugPrint('❌ [TTS_MOBILE] ❌ Erro: $msg');
        if (!completer.isCompleted) {
          completer.completeError(msg);
        }
        if (originalError != null) {
          _flutterTts.setErrorHandler(originalError);
        }
      });

      final result = await _flutterTts.speak(cleanText);
      if (result != 1) {
        _isSpeaking = false;
        debugPrint('❌ [TTS_MOBILE] ❌ Erro ao falar: $result');
        if (!completer.isCompleted) {
          completer.completeError('Erro ao falar: $result');
        }
        // Restaura os handlers
        if (originalCompletion != null) {
          _flutterTts.setCompletionHandler(originalCompletion);
        }
        if (originalError != null) {
          _flutterTts.setErrorHandler(originalError);
        }
        return completer.future;
      }

      // 🔥 AGUARDA O COMPLETION SER CHAMADO
      await completer.future;

      // 🔥 RESTAURA OS HANDLERS
      if (originalCompletion != null) {
        _flutterTts.setCompletionHandler(originalCompletion);
      }
      if (originalError != null) {
        _flutterTts.setErrorHandler(originalError);
      }

    } catch (e) {
      _isSpeaking = false;
      debugPrint('❌ [TTS_MOBILE] ❌ Exceção: $e');
      rethrow;
    }
  }

  @override
  Future<void> stopAndClear() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    debugPrint('🛑 [TTS_MOBILE] 🛑 Parado');
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  int get queueLength => 0;

  @override
  void dispose() {
    _flutterTts.stop();
    _isSpeaking = false;
  }
}
