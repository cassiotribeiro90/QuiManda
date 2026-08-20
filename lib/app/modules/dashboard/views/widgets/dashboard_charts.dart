import 'package:flutter/material.dart';

class DashboardCharts extends StatelessWidget {
  final List<dynamic> pedidosPorDia;
  final List<dynamic> faturamentoPorMes;
  final List<dynamic> pedidosPorStatus;
  final List<dynamic> pedidosPorPagamento;
  final bool isMobile;

  const DashboardCharts({
    super.key,
    required this.pedidosPorDia,
    required this.faturamentoPorMes,
    required this.pedidosPorStatus,
    required this.pedidosPorPagamento,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final statusCard = _buildCard(
      isDark,
      title: 'Status dos Pedidos',
      subtitle: 'Distribuição atual',
      child: _buildStatusList(isDark),
    );

    final paymentCard = _buildCard(
      isDark,
      title: 'Formas de Pagamento',
      subtitle: 'Distribuição',
      child: _buildPaymentList(isDark),
    );

    if (isMobile) {
      return Column(
        children: [
          statusCard,
          const SizedBox(height: 16),
          paymentCard,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: statusCard),
        const SizedBox(width: 16),
        Expanded(child: paymentCard),
      ],
    );
  }

  Widget _buildCard(bool isDark, {required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatusList(bool isDark) {
    if (pedidosPorStatus.isEmpty) {
      return Text('Nenhum pedido ainda', style: TextStyle(fontSize: 14, color: Colors.grey.shade500));
    }

    final total = pedidosPorStatus.fold<int>(0, (sum, item) => sum + ((item['total'] ?? 0) as int));

    return Column(
      children: pedidosPorStatus.map((item) {
        final valor = item['total'] ?? 0;
        final percent = total > 0 ? (valor / total) * 100 : 0.0;
        final label = item['status'] ?? '';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.black87),
                ),
              ),
              Text(
                '$valor (${percent.toStringAsFixed(1)}%)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentList(bool isDark) {
    if (pedidosPorPagamento.isEmpty) {
      return Text('Nenhum pagamento ainda', style: TextStyle(fontSize: 14, color: Colors.grey.shade500));
    }

    final total = pedidosPorPagamento.fold<int>(0, (sum, item) => sum + ((item['total'] ?? 0) as int));

    return Column(
      children: pedidosPorPagamento.map((item) {
        final valor = item['total'] ?? 0;
        final percent = total > 0 ? (valor / total) * 100 : 0.0;
        final label = item['forma_pagamento'] ?? '';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.black87),
                ),
              ),
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}