/// Interface para serviços de Text-to-Speech
abstract class TtsInterface {
  /// Inicializa o serviço
  Future<void> init();

  /// Adiciona um texto à fila para ser falado
  Future<void> speak(String text);

  /// Registra interação do usuário (necessário para Web)
  void onUserInteraction();

  /// Para a fala atual e limpa a fila
  Future<void> stopAndClear();

  /// Retorna se está falando
  bool get isSpeaking;

  /// Retorna o tamanho da fila
  int get queueLength;

  /// Libera recursos
  void dispose();
}
