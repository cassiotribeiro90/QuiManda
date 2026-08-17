// lib/app/modules/pedidos/widgets/pedido_status_section.dart
import 'package:flutter/material.dart';
import '../model/pedido_model.dart';
import 'pedido_card_widget.dart';

class PedidoStatusSection extends StatelessWidget {
  final String status;
  final String label;
  final int total;
  final List<PedidoModel> pedidos;
  final Function(int) onAceitar;
  final Function(int) onRecusar;
  final Function(PedidoModel) onCardTap;

  const PedidoStatusSection({
    super.key,
    required this.status,
    required this.label,
    required this.total,
    required this.pedidos,
    required this.onAceitar,
    required this.onRecusar,
    required this.onCardTap,
  });

  Color get _corStatus {
    switch (status) {
      case 'novo': return Colors.red;
      case 'em_preparo': return Colors.orange;
      case 'pronto': return Colors.green;
      case 'saiu': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData get _iconeStatus {
    switch (status) {
      case 'novo': return Icons.notifications_active;
      case 'em_preparo': return Icons.timer;
      case 'pronto': return Icons.check_circle;
      case 'saiu': return Icons.delivery_dining;
      default: return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔥 Cabeçalho da seção
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(_iconeStatus, color: _corStatus, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: _corStatus.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$total',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _corStatus,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 🔥 Lista de pedidos da seção
        ...pedidos.map((pedido) => PedidoCardWidget(
          pedido: pedido,
          onTap: () => onCardTap(pedido),
          onAceitar: () => onAceitar(pedido.id),
          onRecusar: () => onRecusar(pedido.id),
        )),
      ],
    );
  }
}
