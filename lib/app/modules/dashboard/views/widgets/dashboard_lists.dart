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
            subtitle: 'Mais vendidos',
            child: _buildTopProdutos(isDark),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard(
            isDark,
            title: 'Top Clientes',
            subtitle: 'Mais fiéis',
            child: _buildTopClientes(isDark),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard(
            isDark,
            title: 'Satisfação',
            subtitle: 'Avaliações',
            child: _buildSatisfacao(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(bool isDark, {required String title, required String subtitle, required Widget child}) {
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
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTopProdutos(bool isDark) {
    if (topProdutos.isEmpty) {
      return Text('Nenhum produto vendido hoje', style: TextStyle(fontSize: 12, color: Colors.grey.shade500));
    }

    return Column(
      children: topProdutos.take(5).map((produto) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  produto['nome'] ?? '',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('${produto['vendas'] ?? 0}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopClientes(bool isDark) {
    if (topClientes.isEmpty) {
      return Text('Nenhum cliente ainda', style: TextStyle(fontSize: 12, color: Colors.grey.shade500));
    }

    return Column(
      children: topClientes.take(5).map((cliente) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  cliente['nome'] ?? 'Sem nome',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('${cliente['total_pedidos'] ?? 0} pedidos', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSatisfacao(bool isDark) {
    final percentual = satisfacao['percentual_positivo'] ?? 0;
    final total = satisfacao['total'] ?? 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$percentual%',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 4),
        Text('Avaliações positivas', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const SizedBox(height: 8),
        Text('$total avaliações', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.black87)),
      ],
    );
  }
}