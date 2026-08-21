import 'dart:async';
import 'dart:html' as html;
import 'tts_interface.dart';

/// Implementação WEB do TTS usando SpeechSynthesis API
class TtsWeb implements TtsInterface {
  final List<String> _queue = [];
  bool _isSpeaking = false;
  bool _isInitialized = false;
  bool _isUserInteracted = false;
  html.SpeechSynthesis? _speechSynthesis;
  Timer? _keepAliveTimer;
  bool _isProcessing = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _speechSynthesis = html.window.speechSynthesis;
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

    if (voices.isEmpty) {
      print('[TTS_WEB] Aguardando vozes...');
      final synth = _speechSynthesis!;
      // Tenta carregar vozes por até 3 segundos
      int attempts = 0;
      while (voices.isEmpty && attempts < 6) {
        await Future.delayed(const Duration(milliseconds: 500));
        voices = synth.getVoices().cast<html.SpeechSynthesisVoice>();
        attempts++;
      }
    }

    print('[TTS_WEB] Vozes: ${voices.length}');
  }

  @override
  void onUserInteraction() {
    _isUserInteracted = true;
    print('[TTS_WEB] Interação registrada');
    
    // 🔥 ATIVA O CONTEXTO UMA ÚNICA VEZ
    if (_speechSynthesis != null && !_isProcessing) {
      _activateContext();
    }
  }

  /// 🔥 ATIVA O CONTEXTO UMA ÚNICA VEZ
  void _activateContext() {
    if (_speechSynthesis == null) return;
    if (_isProcessing) return;

    _isProcessing = true;
    try {
      // 🔥 FALA UM TEXTO CURTO E CANCELA
      final utterance = html.SpeechSynthesisUtterance(' ');
      utterance.lang = 'pt-BR';
      utterance.volume = 0.1;
      _speechSynthesis!.speak(utterance);
      
      Future<void>.delayed(const Duration(milliseconds: 100), () {
        // 🔥 SÓ CANCELA SE NÃO HOUVER FALA EM ANDAMENTO
        final synth = _speechSynthesis;
        if (synth != null && ((synth.speaking ?? false) == false || _queue.isEmpty)) {
          synth.cancel();
        }
        _isProcessing = false;
        print('[TTS_WEB] Contexto ativado');
        // 🔥 INICIA KEEP-ALIVE APÓS ATIVAÇÃO
        _startKeepAlive();
        // 🔥 PROCESSA A FILA
        _processNext();
      });
    } catch (e) {
      _isProcessing = false;
      print('[TTS_WEB] Erro na ativação: $e');
    }
  }

  void _startKeepAlive() {
    _stopKeepAlive();
    // 🔥 KEEP-ALIVE A CADA 15 SEGUNDOS (menos frequente)
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      final synth = _speechSynthesis;
      // 🔥 SÓ EXECUTA KEEP-ALIVE SE NÃO ESTIVER FALANDO
      if (synth != null && 
          _isUserInteracted && 
          !_isSpeaking && 
          (synth.speaking ?? false) == false && 
          _queue.isEmpty) {
        try {
          final utterance = html.SpeechSynthesisUtterance(' ');
          utterance.lang = 'pt-BR';
          utterance.volume = 0;
          synth.speak(utterance);
          // 🔥 CANCELA SEM INTERROMPER FALA ATIVA
          Future<void>.delayed(const Duration(milliseconds: 50), () {
            if ((synth.speaking ?? false) == false) {
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

  /// 🔥 LIMPA TEXTO (remove emojis)
  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'[^\w\s,.!?\-]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    final cleanText = _cleanText(text);
    if (cleanText.isEmpty) return;

    if (!_isUserInteracted) {
      print('[TTS_WEB] Aguardando interação');
      _queue.add(cleanText);
      return;
    }

    // 🔥 NÃO ADICIONA DUPLICATAS CONSECUTIVAS
    if (_queue.isNotEmpty && _queue.last == cleanText) {
      print('[TTS_WEB] Texto duplicado ignorado: "$cleanText"');
      return;
    }

    _queue.add(cleanText);
    print('[TTS_WEB] Fila: ${_queue.length}');

    if (!_isSpeaking && !_isProcessing && _speechSynthesis != null) {
      _processNext();
    }
  }

  void _processNext() {
    // 🔥 PREVINE PROCESSAMENTO MÚLTIPLO
    if (_isProcessing) return;
    if (_isSpeaking) return;
    if (_queue.isEmpty) return;
    if (_speechSynthesis == null) return;

    _isProcessing = true;
    final nextText = _queue.removeAt(0);
    print('[TTS_WEB] Falando: "$nextText" (restam ${_queue.length})');

    try {
      final utterance = html.SpeechSynthesisUtterance(nextText);

      utterance.lang = 'pt-BR';
      utterance.rate = 0.9;
      utterance.pitch = 1.0;
      utterance.volume = 1.0;

      // 🔥 SELECIONA VOZ
      final voices = _speechSynthesis!.getVoices();
      html.SpeechSynthesisVoice? ptVoice;
      try {
        ptVoice = voices.firstWhere(
          (v) => v.lang != null && v.lang!.startsWith('pt'),
        );
      } catch (_) {
        ptVoice = voices.isNotEmpty ? voices.first : null;
      }
      
      if (ptVoice != null) {
        utterance.voice = ptVoice;
      }

      // 🔥 HANDLERS - SIMPLES E DIRETOS
      utterance.onStart.listen((_) {
        _isSpeaking = true;
        _isProcessing = false;
        print('[TTS_WEB] 🔊 Falando');
      });

      utterance.onEnd.listen((_) {
        _isSpeaking = false;
        _isProcessing = false;
        print('[TTS_WEB] ✅ Terminou');
        // 🔥 PRÓXIMO APÓS 500ms
        Future.delayed(const Duration(milliseconds: 500), _processNext);
      });

      utterance.onError.listen((event) {
        _isSpeaking = false;
        _isProcessing = false;
        print('[TTS_WEB] ❌ Erro na fala');
        // 🔥 TENTA O PRÓXIMO APÓS 1s
        Future.delayed(const Duration(seconds: 1), _processNext);
      });

      _speechSynthesis!.speak(utterance);
    } catch (e) {
      _isSpeaking = false;
      _isProcessing = false;
      print('[TTS_WEB] ❌ Exceção: $e');
      Future.delayed(const Duration(seconds: 1), _processNext);
    }
  }

  @override
  Future<void> stopAndClear() async {
    _stopKeepAlive();
    if (_speechSynthesis != null) {
      _speechSynthesis!.cancel();
    }
    _queue.clear();
    _isSpeaking = false;
    _isProcessing = false;
    print('[TTS_WEB] Parado');
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  int get queueLength => _queue.length;

  @override
  void dispose() {
    _stopKeepAlive();
    stopAndClear();
  }
}
