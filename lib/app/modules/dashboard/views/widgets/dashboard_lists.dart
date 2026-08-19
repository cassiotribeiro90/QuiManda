import 'package:flutter/material.dart';

class DashboardLists extends StatelessWidget {
  final List<dynamic> topProdutos;
  final List<dynamic> topClientes;
  final List<dynamic> horariosPico;
  final Map<String, dynamic> satisfacao;

  const DashboardLists({
    super.key,
    required this.topProdutos,
    required this.topClientes,
    required this.horariosPico,
    required this.satisfacao,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildCard(
            isDark,
            title: 'Top Produtos',
            child: _buildList(isDark, topProdutos, 'nome', 'vendas'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard(
            isDark,
            title: 'Top Clientes',
            child: _buildList(isDark, topClientes, 'nome', 'total_pedidos'),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(bool isDark, {required String title, required Widget child}) {
    return Container(
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
          child,
        ],
      ),
    );
  }

  Widget _buildList(bool isDark, List<dynamic> list, String keyLabel, String keyValue) {
    if (list.isEmpty) return const Text('Nenhum dado disponível');
    return Column(
      children: list.take(5).map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item[keyLabel] ?? '', style: const TextStyle(fontSize: 12)),
              Text('${item[keyValue] ?? 0}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
