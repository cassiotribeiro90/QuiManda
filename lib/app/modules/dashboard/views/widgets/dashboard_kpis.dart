import 'package:flutter/material.dart';

class DashboardKpis extends StatelessWidget {
  final Map<String, dynamic> kpis;

  const DashboardKpis({super.key, required this.kpis});

  String _formatarNumero(dynamic valor) {
    if (valor == null) return '0';
    final numero = valor is num ? valor.toDouble() : double.tryParse(valor.toString()) ?? 0;
    return numero.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cards = [
      _KpiCard(
        icon: Icons.receipt_long,
        color: Colors.blue,
        title: 'Pedidos Hoje',
        value: '${kpis['pedidos_hoje'] ?? 0}',
        subtitle: '${kpis['pedidos_semana'] ?? 0} na semana',
      ),
      _KpiCard(
        icon: Icons.attach_money,
        color: Colors.green,
        title: 'Faturamento (mês)',
        value: 'R\$ ${_formatarNumero(kpis['faturamento_mes'] ?? 0)}',
        subtitle: 'R\$ ${_formatarNumero(kpis['faturamento_hoje'] ?? 0)} hoje',
      ),
      _KpiCard(
        icon: Icons.payments,
        color: Colors.teal,
        title: 'Ticket Médio',
        value: 'R\$ ${_formatarNumero(kpis['ticket_medio'] ?? 0)}',
        subtitle: 'Por pedido',
      ),
      _KpiCard(
        icon: Icons.star,
        color: Colors.purple,
        title: 'Avaliação Média',
        value: '${(kpis['avaliacao_media'] ?? 0).toStringAsFixed(1)}',
        subtitle: '${kpis['clientes_unicos'] ?? 0} clientes únicos',
      ),
    ];

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1200 ? 4 : (width > 600 ? 2 : 2);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: cards,
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;

  const _KpiCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
