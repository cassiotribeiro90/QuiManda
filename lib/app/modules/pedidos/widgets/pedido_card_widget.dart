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
      child: Card(
        elevation: isNovo ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isNovo ? BorderSide(color: Colors.red.shade300, width: 1.5) : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 Cabeçalho: Código + Status + Timer
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pedido #${pedido.codigo ?? pedido.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

              // 🔥 Cliente
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      pedido.clienteNome ?? 'Cliente',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (pedido.clienteTelefone != null) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      pedido.clienteTelefone!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),

              // 🔥 Resumo: Itens + Total
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${pedido.itens.length} itens',
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
              const SizedBox(height: 8),

              // 🔥 Lista de Itens (sempre visível)
              if (pedido.itens.isNotEmpty) ...[
                const Divider(thickness: 1),
                const Text(
                  'Itens:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                // Se muitos itens, coloca em um container com altura máxima e scroll
                if (pedido.itens.length > 5)
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: pedido.itens.length,
                      itemBuilder: (context, index) {
                        final item = pedido.itens[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                '${item.quantidade}x',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item.nome)),
                              Text('R\$ ${(item.precoUnitario * item.quantidade).toStringAsFixed(2)}'),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                else
                  Column(
                    children: pedido.itens.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '${item.quantidade}x',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item.nome)),
                          Text('R\$ ${(item.precoUnitario * item.quantidade).toStringAsFixed(2)}'),
                        ],
                      ),
                    )).toList(),
                  ),
                const SizedBox(height: 8),
              ],

              // 🔥 Endereço
              if (pedido.enderecoEntrega != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatEndereco(pedido.enderecoEntrega),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // 🔥 Forma de pagamento
              if (pedido.formaPagamento != null) ...[
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
                const SizedBox(height: 4),
              ],

              // 🔥 Observações
              if (pedido.observacoes != null && pedido.observacoes!.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.comment_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pedido.observacoes!,
                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // 🔥 Botões de ação (sempre visíveis)
              const Divider(thickness: 1),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _getAcaoPrincipal(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getCorBotaoPrincipal(),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        _getTextoBotaoPrincipal(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isNovo)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onRecusar,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    if (pedido.isNovo) return 'ACEITAR';
    if (pedido.isPreparando) return 'PRONTO';
    if (pedido.isPronto) return 'SAIU';
    if (pedido.isSaiu) return 'ENTREGUE';
    return 'DETALHES';
  }

  Color _getCorBotaoPrincipal() {
    if (pedido.isNovo) return Colors.green;
    if (pedido.isPreparando) return Colors.orange;
    if (pedido.isPronto) return Colors.blue;
    if (pedido.isSaiu) return Colors.purple;
    return Colors.grey;
  }

  VoidCallback? _getAcaoPrincipal() {
    if (pedido.isNovo ||
        pedido.isPreparando ||
        pedido.isPronto ||
        pedido.isSaiu) {
      return onAceitar;
    }
    return null;
  }
}
