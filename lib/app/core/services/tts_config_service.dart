import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para gerenciar as configurações do TTS
class TtsConfigService {
  final SharedPreferences _prefs;
  static const String _keyTtsEnabled = 'tts_enabled';

  TtsConfigService(this._prefs);

  /// Verifica se o TTS está habilitado
  bool isTtsEnabled() {
    return _prefs.getBool(_keyTtsEnabled) ?? true; // Padrão: ativo
  }

  /// Salva o estado do TTS
  Future<void> setTtsEnabled(bool enabled) async {
    await _prefs.setBool(_keyTtsEnabled, enabled);
  }

  /// Alterna o estado do TTS
  Future<bool> toggleTts() async {
    final current = isTtsEnabled();
    final newState = !current;
    await setTtsEnabled(newState);
    return newState;
  }
}
