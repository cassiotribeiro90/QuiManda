import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
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
      case 'novo': return AppTheme.primaryColor;
      case 'em_preparo': return AppTheme.warningColor;
      case 'pronto': return AppTheme.successColor;
      case 'saiu': return AppTheme.infoColor;
      default: return Colors.grey;
    }
  }

  IconData get _iconeStatus {
    switch (status) {
      case 'novo': return Icons.notifications_outlined;
      case 'em_preparo': return Icons.timer_outlined;
      case 'pronto': return Icons.check_circle_outline;
      case 'saiu': return Icons.delivery_dining_outlined;
      default: return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(_iconeStatus, color: _corStatus, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: _corStatus.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$total',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _corStatus,
                  ),
                ),
              ),
            ],
          ),
        ),
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