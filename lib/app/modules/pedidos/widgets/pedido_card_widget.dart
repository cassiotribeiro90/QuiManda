// lib/app/modules/pedidos/widgets/pedido_card_widget.dart
import 'package:flutter/material.dart';
import '../model/pedido_model.dart';
import 'timer_widget.dart';
import 'status_badge_widget.dart';

class PedidoCardWidget extends StatelessWidget {
  final PedidoModel pedido;
  final VoidCallback onTap;
  final VoidCallback onAceitar;
  final VoidCallback onRecusar;

  const PedidoCardWidget({
    Key? key,
    required this.pedido,
    required this.onTap,
    required this.onAceitar,
    required this.onRecusar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isNovo = pedido.status == 'novo';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: isNovo ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isNovo ? BorderSide(color: Colors.red.shade300, width: 1.5) : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 Linha 1: Código + Status + Timer
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pedido #${pedido.codigo ?? pedido.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                const SizedBox(height: 8),
                // 🔥 Linha 2: Cliente
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      pedido.clienteNome ?? 'Cliente',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 🔥 Linha 3: Itens + Total
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${pedido.itens?.length ?? 0} itens',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      'R\$ ${pedido.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                // 🔥 Linha 4: Endereço (se disponível)
                if (pedido.enderecoEntrega != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatEndereco(pedido.enderecoEntrega),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                // 🔥 Linha 5: Forma de Pagamento
                if (pedido.formaPagamento != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.payment_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _formatPagamento(pedido.formaPagamento!, pedido.trocoPara),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
                // 🔥 Linha 6: Observações
                if (pedido.observacoes != null && pedido.observacoes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.comment_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          pedido.observacoes!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                // 🔥 Botões de ação
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Botão principal (varia conforme status)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAceitar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getCorBotaoPrincipal(),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _getTextoBotaoPrincipal(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botão secundário
                    if (isNovo)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onRecusar,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('RECUSAR'),
                        ),
                      )
                    else
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('VER DETALHES'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatEndereco(dynamic endereco) {
    if (endereco == null) return '';
    if (endereco is String) return endereco;
    try {
      final e = endereco as Map<String, dynamic>;
      final parts = [
        e['logradouro'] ?? e['rua'] ?? '',
        e['numero'] ?? '',
        e['bairro'] ?? '',
        e['cidade'] ?? '',
      ].where((p) => p.toString().isNotEmpty);
      return parts.join(', ');
    } catch (_) {
      return endereco.toString();
    }
  }

  String _formatPagamento(String forma, double? troco) {
    final labels = {
      'credito': 'Cartão de Crédito',
      'debito': 'Cartão de Débito',
      'dinheiro': 'Dinheiro',
      'pix': 'PIX',
      'vr': 'Vale Refeição',
    };
    String label = labels[forma] ?? forma;
    if (forma == 'dinheiro' && troco != null && troco > 0) {
      label += ' (Troco para R\$ ${troco.toStringAsFixed(2)})';
    }
    return label;
  }

  String _getTextoBotaoPrincipal() {
    switch (pedido.status) {
      case 'novo': return 'ACEITAR';
      case 'preparando': return 'PRONTO';
      case 'pronto': return 'SAIU';
      case 'saiu': return 'ENTREGUE';
      default: return 'DETALHES';
    }
  }

  Color _getCorBotaoPrincipal() {
    switch (pedido.status) {
      case 'novo': return Colors.green;
      case 'preparando': return Colors.orange;
      case 'pronto': return Colors.blue;
      case 'saiu': return Colors.purple;
      default: return Colors.grey;
    }
  }
}
