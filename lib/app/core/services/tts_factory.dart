import 'tts_interface.dart';
import 'tts_factory_mobile.dart' if (dart.library.html) 'tts_factory_web.dart';

/// Fábrica para criar a implementação correta do TTS
class TtsFactory {
  static TtsInterface create() {
    return getTtsImplementation();
  }
}
