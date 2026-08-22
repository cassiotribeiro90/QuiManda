class NotificationPayload {
  final String? pedidoId;
  final String? type;
  final String? status;

  NotificationPayload({
    this.pedidoId,
    this.type,
    this.status,
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      pedidoId: map['pedido_id']?.toString(),
      type: map['type']?.toString(),
      status: map['status']?.toString(),
    );
  }
}
