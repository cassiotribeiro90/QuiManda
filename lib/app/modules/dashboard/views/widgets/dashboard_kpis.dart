import 'package:flutter/material.dart';

class DashboardKpis extends StatelessWidget {
  final Map<String, dynamic> kpis;
  final bool isMobile;

  const DashboardKpis({super.key, required this.kpis, this.isMobile = false});

  /// Converte qualquer valor (num ou string) para double e formata com 2 casas decimais.
  String _formatarNumero(dynamic valor) {
    if (valor == null) return '0';
    final numero = valor is num ? valor.toDouble() : double.tryParse(valor.toString()) ?? 0;
    return numero.toStringAsFixed(2).replaceAll('.', ',');
  }

  /// Converte para double com 1 casa decimal (para avaliação média).
  String _formatarAvaliacao(dynamic valor) {
    if (valor == null) return '0,0';
    final numero = valor is num ? valor.toDouble() : double.tryParse(valor.toString()) ?? 0;
    return numero.toStringAsFixed(1).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
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
        value: _formatarAvaliacao(kpis['avaliacao_media'] ?? 0),
        subtitle: '${kpis['clientes_unicos'] ?? 0} clientes únicos',
      ),
    ];

    final crossAxisCount = isMobile ? 1 : 2;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      mainAxisExtent: isMobile ? 110 : 100,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone à esquerda
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          const SizedBox(width: 12),

          // Conteúdo à direita
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}