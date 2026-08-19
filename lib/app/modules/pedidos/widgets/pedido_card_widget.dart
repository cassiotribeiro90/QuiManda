import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../model/pedido_model.dart';
import 'timer_widget.dart';
import 'status_badge_widget.dart';

class PedidoCardWidget extends StatelessWidget {
  final PedidoModel pedido;
  final VoidCallback onTap;
  final VoidCallback onAceitar;
  final VoidCallback onRecusar;

  const PedidoCardWidget({
    super.key,
    required this.pedido,
    required this.onTap,
    required this.onAceitar,
    required this.onRecusar,
  });

  @override
  Widget build(BuildContext context) {
    final isNovo = pedido.isNovo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isNovo ? AppTheme.primaryColor.withOpacity(0.2) : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pedido #${pedido.codigo ?? pedido.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadgeWidget(status: pedido.status),
                const SizedBox(width: 8),
                TimerWidget(tempoEspera: pedido.tempoEspera),
              ],
            ),
            const SizedBox(height: 12),

            // Cliente
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    pedido.clienteNome ?? 'Cliente',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF334155),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (pedido.clienteTelefone != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.phone, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    pedido.clienteTelefone!,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Divider
            Container(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 12),

            // Itens + Total
            Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  '${pedido.itens.length} itens',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
                ),
                const Spacer(),
                Text(
                  'R\$ ${pedido.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Lista de Itens
            if (pedido.itens.isNotEmpty) ...[
              const Text(
                'Itens:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              Column(
                children: pedido.itens.take(4).map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantidade}x',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.nome,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'R\$ ${(item.precoUnitario * item.quantidade).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              if (pedido.itens.length > 4)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+ ${pedido.itens.length - 4} itens...',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ),
              const SizedBox(height: 12),
            ],

            // Botões
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _getAcaoPrincipal(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getCorBotaoPrincipal(),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      _getTextoBotaoPrincipal(),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isNovo ? onRecusar : onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isNovo ? AppTheme.dangerColor : AppTheme.infoColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(
                        color: isNovo ? AppTheme.dangerColor.withOpacity(0.3) : AppTheme.infoColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      isNovo ? 'Recusar' : 'Ver detalhes',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTextoBotaoPrincipal() {
    if (pedido.isNovo) return 'Aceitar';
    if (pedido.isPreparando) return 'Marcar pronto';
    if (pedido.isPronto) return 'Saiu';
    if (pedido.isSaiu) return 'Entregue';
    return 'Detalhes';
  }

  Color _getCorBotaoPrincipal() {
    if (pedido.isNovo) return AppTheme.successColor;
    if (pedido.isPreparando) return AppTheme.warningColor;
    if (pedido.isPronto) return AppTheme.infoColor;
    if (pedido.isSaiu) return AppTheme.primaryColor;
    return Colors.grey;
  }

  VoidCallback? _getAcaoPrincipal() {
    if (pedido.isNovo || pedido.isPreparando || pedido.isPronto || pedido.isSaiu) {
      return onAceitar;
    }
    return null;
  }
}