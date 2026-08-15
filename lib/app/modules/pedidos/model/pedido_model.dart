class PedidoModel {
  final String id;
  final String cliente;
  final double valor;
  final String status;
  final DateTime data;

  PedidoModel({
    required this.id,
    required this.cliente,
    required this.valor,
    required this.status,
    required this.data,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      id: json['id'],
      cliente: json['cliente'],
      valor: (json['valor'] as num).toDouble(),
      status: json['status'],
      data: DateTime.parse(json['data']),
    );
  }
}
