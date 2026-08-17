// lib/app/modules/pedidos/widgets/status_badge_widget.dart
import 'package:flutter/material.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String status;

  const StatusBadgeWidget({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: config.color,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'novo':
        return _StatusConfig(Colors.blue, 'NOVO');
      case 'em_preparo':
        return _StatusConfig(Colors.orange, 'PREPARANDO');
      case 'pronto':
        return _StatusConfig(Colors.green, 'PRONTO');
      case 'saiu':
        return _StatusConfig(Colors.purple, 'SAIU');
      case 'entregue':
        return _StatusConfig(Colors.green, 'ENTREGUE');
      case 'cancelado':
        return _StatusConfig(Colors.red, 'CANCELADO');
      case 'recusado':
        return _StatusConfig(Colors.red, 'RECUSADO');
      default:
        return _StatusConfig(Colors.grey, status.toUpperCase());
    }
  }
}

class _StatusConfig {
  final Color color;
  final String label;
  _StatusConfig(this.color, this.label);
}
