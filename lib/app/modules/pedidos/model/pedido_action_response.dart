import '../cubit/pedidos_state.dart';

class PedidoActionResponse {
  final int pedidoId;
  final String status;
  final String? statusAnterior;
  final List<GrupoPedidos>? grupos;
  final String message;

  PedidoActionResponse({
    required this.pedidoId,
    required this.status,
    this.statusAnterior,
    this.grupos,
    required this.message,
  });

  factory PedidoActionResponse.fromJson(Map<String, dynamic> json) {
    return PedidoActionResponse(
      pedidoId: json['pedido_id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      statusAnterior: json['status_anterior'] as String?,
      message: json['message'] as String? ?? '',
      grupos: json['grupos'] != null
          ? (json['grupos'] as List<dynamic>)
              .map((e) => GrupoPedidos.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
