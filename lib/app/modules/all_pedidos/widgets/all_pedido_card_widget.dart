// lib/app/modules/all_pedidos/widgets/all_pedido_card_widget.dart

import 'package:flutter/material.dart';
import '../models/all_pedido_model.dart';

class AllPedidoCardWidget extends StatelessWidget {
  final AllPedido pedido;
  final VoidCallback onTap;
  final bool showDivider;

  const AllPedidoCardWidget({
    super.key,
    required this.pedido,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = pedido.statusColor;

    return Column(
      children: [
        // ⭐ ITEM FLAT (SEM CARD)
        InkWell(
          onTap: onTap,
          splashColor: statusColor.withOpacity(0.1),
          highlightColor: statusColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                // ⭐ INDICADOR DE STATUS (bolinha colorida)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),

                // ⭐ CONTEÚDO PRINCIPAL
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Linha 1: Código + Status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pedido.codigo,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            pedido.statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Linha 2: Cliente
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 13,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pedido.clienteNome ?? 'Cliente',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // Linha 3: Itens (se houver)
                      if (pedido.itens != null && pedido.itens!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 13,
                              color: isDark ? Colors.grey[500] : Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                pedido.itens!.take(3).map((i) => i.nome).join(' • '),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Linha 4: Valor + Data
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'R\$ ${pedido.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(pedido.criadoEm),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : Colors.grey[500],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ⭐ DIVIDER (separador entre itens)
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            indent: 22,
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) {
      return 'Hoje ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d atrás';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}