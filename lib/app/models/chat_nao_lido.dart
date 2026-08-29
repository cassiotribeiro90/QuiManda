class ChatNaoLido {
  final int chatId;
  final String clienteNome;
  final String ultimaMensagem;
  final String dataUltimaMensagem;
  final int naoLidas;
  final String? clienteAvatar;

  ChatNaoLido({
    required this.chatId,
    required this.clienteNome,
    required this.ultimaMensagem,
    required this.dataUltimaMensagem,
    required this.naoLidas,
    this.clienteAvatar,
  });

  factory ChatNaoLido.fromJson(Map<String, dynamic> json) {
    return ChatNaoLido(
      chatId: json['chat_id'] ?? 0,
      clienteNome: json['cliente_nome'] ?? 'Cliente',
      ultimaMensagem: json['ultima_mensagem'] ?? 'Nova mensagem',
      dataUltimaMensagem: json['data_ultima_mensagem'] ?? '',
      naoLidas: json['nao_lidas'] ?? 0,
      clienteAvatar: json['cliente_avatar'],
    );
  }
}
