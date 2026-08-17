// lib/app/modules/pedidos/widgets/timer_widget.dart
import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int tempoEspera; // em minutos

  const TimerWidget({super.key, required this.tempoEspera});

  @override
  Widget build(BuildContext context) {
    final isUrgent = tempoEspera > 5;
    final color = isUrgent ? Colors.red : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${tempoEspera}min',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
