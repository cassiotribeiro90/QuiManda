import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardCharts extends StatelessWidget {
  final List<dynamic> pedidosPorDia;
  final List<dynamic> faturamentoPorMes;
  final List<dynamic> pedidosPorStatus;
  final List<dynamic> pedidosPorPagamento;

  const DashboardCharts({
    super.key,
    required this.pedidosPorDia,
    required this.faturamentoPorMes,
    required this.pedidosPorStatus,
    required this.pedidosPorPagamento,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildCard(
                isDark,
                title: 'Pedidos por Dia',
                height: 280,
                child: const Center(child: Text('Gráfico de barras pendente')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCard(
                isDark,
                title: 'Faturamento Mensal',
                height: 280,
                child: const Center(child: Text('Gráfico de linha pendente')),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(bool isDark, {required String title, required double height, required Widget child}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}
