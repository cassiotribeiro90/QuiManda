import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'tts_interface.dart';

/// Implementação WEB do TTS usando SpeechSynthesis API
class TtsWeb implements TtsInterface {
  bool _isSpeaking = false;
  bool _isInitialized = false;
  bool _isUserInteracted = false;
  web.SpeechSynthesis? _speechSynthesis;
  Timer? _keepAliveTimer;
  bool _isProcessing = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _speechSynthesis = web.window.speechSynthesis;
      if (_speechSynthesis == null) {
        print('[TTS_WEB] SpeechSynthesis não disponível');
        return;
      }

      await _loadVoices();
      _isInitialized = true;
      print('[TTS_WEB] Inicializado com sucesso');
    } catch (e) {
      print('[TTS_WEB] Erro na inicialização: $e');
    }
  }

  Future<void> _loadVoices() async {
    if (_speechSynthesis == null) return;

    var voices = _speechSynthesis!.getVoices();

    if (voices.length == 0) {
      print('[TTS_WEB] Aguardando vozes...');
      final synth = _speechSynthesis!;
      int attempts = 0;
      while (voices.length == 0 && attempts < 6) {
        await Future.delayed(const Duration(milliseconds: 500));
        voices = synth.getVoices();
        attempts++;
      }
    }

    print('[TTS_WEB] Vozes: ${voices.length}');
  }

  @override
  void onUserInteraction() {
    _isUserInteracted = true;
    print('[TTS_WEB] Interação registrada');

    if (_speechSynthesis != null && !_isProcessing) {
      _activateContext();
    }
  }

  void _activateContext() {
    if (_speechSynthesis == null) return;
    if (_isProcessing) return;

    _isProcessing = true;
    try {
      final utterance = web.SpeechSynthesisUtterance.new(' ');
      utterance.lang = 'pt-BR';
      utterance.volume = 0.1;
      _speechSynthesis!.speak(utterance);

      Future<void>.delayed(const Duration(milliseconds: 100), () {
        final synth = _speechSynthesis;
        if (synth != null && !synth.speaking) {
          synth.cancel();
        }
        _isProcessing = false;
        print('[TTS_WEB] Contexto ativado');
        _startKeepAlive();
      });
    } catch (e) {
      _isProcessing = false;
      print('[TTS_WEB] Erro na ativação: $e');
    }
  }

  void _startKeepAlive() {
    _stopKeepAlive();
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      final synth = _speechSynthesis;
      if (synth != null &&
          _isUserInteracted &&
          !_isSpeaking &&
          !synth.speaking) {
        try {
          final utterance = web.SpeechSynthesisUtterance.new(' ');
          utterance.lang = 'pt-BR';
          utterance.volume = 0;
          synth.speak(utterance);
          Future<void>.delayed(const Duration(milliseconds: 50), () {
            if (!synth.speaking) {
              synth.cancel();
            }
          });
        } catch (e) {
          // Ignora
        }
      }
    });
  }

  void _stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

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

    if (!_isUserInteracted) {
      print('[TTS_WEB] Aguardando interação');
      return;
    }

    if (_isSpeaking) {
      print('[TTS_WEB] ⚠️ Já está falando, ignorando: "$cleanText"');
      return;
    }

    if (_speechSynthesis == null) return;

    print('[TTS_WEB] 🔊 Falando: "$cleanText"');

    // 🔥 COMPLETER PARA AGUARDAR O FIM DA FALA
    final completer = Completer<void>();

    try {
      final utterance = web.SpeechSynthesisUtterance.new(cleanText);

      utterance.lang = 'pt-BR';
      utterance.rate = 0.9;
      utterance.pitch = 1.0;
      utterance.volume = 1.0;

      // 🔥 SELECIONA VOZ FEMININA EM PORTUGUÊS
      final voices = _speechSynthesis!.getVoices();
      web.SpeechSynthesisVoice? selectedVoice;
      final voicesList = voices.toDart;

      for (final voice in voicesList) {
        final name = voice.name.toLowerCase();
        final lang = voice.lang?.toLowerCase() ?? '';
        if (lang.startsWith('pt') &&
            (name.contains('female') ||
                name.contains('feminina') ||
                name.contains('samantha') ||
                name.contains('maria') ||
                name.contains('ana'))) {
          selectedVoice = voice;
          break;
        }
      }

      if (selectedVoice == null) {
        try {
          selectedVoice = voicesList.firstWhere(
                (v) => v.lang != null && v.lang!.startsWith('pt'),
          );
        } catch (_) {
          selectedVoice = voicesList.isNotEmpty ? voicesList.first : null;
        }
      }

      if (selectedVoice != null) {
        utterance.voice = selectedVoice;
        print('[TTS_WEB] Voz selecionada: ${selectedVoice.name} (${selectedVoice.lang})');
      } else {
        print('[TTS_WEB] ⚠️ Nenhuma voz disponível');
      }

      // 🔥 HANDLERS COM COMPLETER
      utterance.addEventListener('start', (_) {
        _isSpeaking = true;
        print('[TTS_WEB] 🔊 Iniciou fala');
      }.toJS);

      utterance.addEventListener('end', (_) {
        _isSpeaking = false;
        print('[TTS_WEB] ✅ Fala finalizada');
        if (!completer.isCompleted) {
          completer.complete();
        }
      }.toJS);

      utterance.addEventListener('error', (_) {
        _isSpeaking = false;
        print('[TTS_WEB] ❌ Erro na fala');
        if (!completer.isCompleted) {
          completer.completeError('Erro na fala');
        }
      }.toJS);

      _speechSynthesis!.speak(utterance);

      // 🔥 AGUARDA O FIM DA FALA
      await completer.future;
    } catch (e) {
      _isSpeaking = false;
      print('[TTS_WEB] ❌ Exceção: $e');
      rethrow;
    }
  }

  @override
  Future<void> stopAndClear() async {
    _stopKeepAlive();
    if (_speechSynthesis != null) {
      _speechSynthesis!.cancel();
    }
    _isSpeaking = false;
    _isProcessing = false;
    print('[TTS_WEB] 🛑 Parado');
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  int get queueLength => 0;

  @override
  void dispose() {
    _stopKeepAlive();
    stopAndClear();
  }
}