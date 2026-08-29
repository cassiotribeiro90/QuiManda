class ChatItem {
  final int id;
  final int? clienteId;
  final String? clienteNome;
  final String? ultimaMensagem;
  final String? dataUltimaMensagem;
  final String status;
  final int naoLidas;
  final int? pedidoId;

  ChatItem({
    required this.id,
    this.clienteId,
    this.clienteNome,
    this.ultimaMensagem,
    this.dataUltimaMensagem,
    required this.status,
    this.naoLidas = 0,
    this.pedidoId,
  });

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      id: json['id'] ?? 0,
      clienteId: json['cliente_id'],
      clienteNome: json['cliente_nome'],
      ultimaMensagem: json['ultima_mensagem'],
      dataUltimaMensagem: json['data_ultima_mensagem'],
      status: json['status'] ?? 'ativo',
      naoLidas: json['nao_lidas'] ?? 0,
      pedidoId: json['pedido_id'],
    );
  }
  
  String get dataUltimaMensagemFormatada {
    if (dataUltimaMensagem == null) return '';
    try {
      final date = DateTime.parse(dataUltimaMensagem!);
      final now = DateTime.now();
      if (date.day == now.day &&
          date.month == now.month &&
          date.year == now.year) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return dataUltimaMensagem!;
    }
  }
}
