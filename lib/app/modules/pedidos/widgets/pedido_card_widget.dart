import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/app_theme.dart';
import '../model/pedido_model.dart';
import 'timer_widget.dart';
import 'status_badge_widget.dart';

class PedidoCardWidget extends StatelessWidget {
  final PedidoModel pedido;
  final VoidCallback onAceitar;
  final VoidCallback onRecusar;
  final void Function(String novoStatus) onAtualizarStatus;
  final VoidCallback? onCancelar;

  const PedidoCardWidget({
    super.key,
    required this.pedido,
    required this.onAceitar,
    required this.onRecusar,
    required this.onAtualizarStatus,
    this.onCancelar,
  });

  // ==================== HELPERS ====================

  String get _numeroPedido {
    final codigo = pedido.codigo;
    if (codigo != null && codigo.isNotEmpty) {
      final partes = codigo.split('-');
      if (partes.length >= 2) {
        final contador = int.tryParse(partes.last) ?? 0;
        return '#${contador.toString().padLeft(3, '0')}';
      }
    }
    return '#${pedido.id}';
  }

  String _limparTelefone(String? telefone) {
    if (telefone == null) return '';
    return telefone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _abrirWhatsApp(String? telefone) async {
    final numero = _limparTelefone(telefone);
    if (numero.isEmpty) return;

    final uri = Uri.parse('https://wa.me/55$numero');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Erro ao abrir WhatsApp: $e');
    }
  }

  String _formatarEndereco(dynamic endereco) {
    if (endereco == null) return '';
    if (endereco is String) return endereco;
    try {
      final e = endereco as Map<String, dynamic>;
      final partes = [
        e['logradouro'] ?? e['rua'] ?? '',
        e['numero'] ?? '',
        e['bairro'] ?? '',
        e['cidade'] ?? '',
      ].where((p) => p.toString().isNotEmpty);
      return partes.join(', ');
    } catch (_) {
      return endereco.toString();
    }
  }

  String _formatarPagamento(String? forma, double? troco) {
    final labels = {
      'credito': 'Cartão de Crédito',
      'debito': 'Cartão de Débito',
      'dinheiro': 'Dinheiro',
      'pix': 'PIX',
      'vr': 'Vale Refeição',
      'cartao_entrega': 'Cartão na Entrega',
      'cartao_credito': 'Cartão de Crédito',
      'cartao_debito': 'Cartão de Débito',
      'vale_refeicao': 'Vale Refeição',
      'vale_alimentacao': 'Vale Alimentação',
      'transferencia': 'Transferência',
      'boleto': 'Boleto',
      'outro': 'Outro',
    };

    String label = labels[forma ?? ''] ?? forma ?? 'Não informado';
    if (forma == 'dinheiro' && troco != null && troco > 0) {
      label += ' (Troco para R\$ ${troco.toStringAsFixed(2)})';
    }
    return label;
  }

  String _getTextoBotaoPrincipal() {
    if (pedido.status == 'novo') return 'ACEITAR';
    if (pedido.status == 'preparando') return 'PRONTO';
    if (pedido.status == 'pronto') return 'SAIU';
    if (pedido.status == 'saiu') return 'ENTREGUE';
    return '';
  }

  VoidCallback? _getAcaoPrincipal() {
    if (pedido.status == 'novo') return onAceitar;
    if (pedido.status == 'preparando') return () => onAtualizarStatus('pronto');
    if (pedido.status == 'pronto') return () => onAtualizarStatus('saiu');
    if (pedido.status == 'saiu') return () => onAtualizarStatus('entregue');
    return null;
  }

  Color _getCorBotaoPrincipal() {
    if (pedido.status == 'novo') return Colors.green;
    if (pedido.status == 'preparando') return Colors.orange;
    if (pedido.status == 'pronto') return Colors.blue;
    if (pedido.status == 'saiu') return Colors.green;
    return Colors.grey;
  }

  bool get _temAcaoPrincipal => _getTextoBotaoPrincipal().isNotEmpty;
  bool get isNovo => pedido.status == 'novo';

  @override
  Widget build(BuildContext context) {
    final isNovo = this.isNovo;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isNovo
                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            width: isNovo ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== CABEÇALHO ====================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _numeroPedido,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadgeWidget(status: pedido.status),
                const SizedBox(width: 8),
                TimerWidget(tempoEspera: pedido.tempoEspera),
              ],
            ),
            const SizedBox(height: 16),

            // ==================== CLIENTE ====================
            Row(
              children: [
                const Icon(Icons.person_outline, size: 20, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pedido.clienteNome ?? 'Cliente',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (pedido.clienteTelefone != null &&
                    pedido.clienteTelefone!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _abrirWhatsApp(pedido.clienteTelefone),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone, size: 16, color: AppTheme.successColor),
                        const SizedBox(width: 4),
                        Text(
                          pedido.clienteTelefone!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Divider
            Container(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
            const SizedBox(height: 12),

            // ==================== ITENS ====================
            Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 20, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Text(
                  '${pedido.itens.length} itens',
                  style: const TextStyle(fontSize: 15, color: Color(0xFF334155)),
                ),
                const Spacer(),
                Text(
                  'R\$ ${pedido.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (pedido.itens.isNotEmpty) ...[
              const Text(
                'Itens do pedido:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              ...pedido.itens.map(
                    (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.quantidade}x',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.nome,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'R\$ ${(item.precoUnitario * item.quantidade).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ==================== ENDEREÇO ====================
            if (pedido.enderecoEntrega != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatarEndereco(pedido.enderecoEntrega),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // ==================== PAGAMENTO ====================
            if (pedido.formaPagamento != null) ...[
              Row(
                children: [
                  const Icon(Icons.payment_outlined, size: 20, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatarPagamento(pedido.formaPagamento, pedido.trocoPara),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // ==================== OBSERVAÇÕES ====================
            if (pedido.observacoes != null && pedido.observacoes!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.comment_outlined, size: 20, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pedido.observacoes!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // ==================== AÇÕES ====================
            if (_temAcaoPrincipal) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _getAcaoPrincipal(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getCorBotaoPrincipal(),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(_getTextoBotaoPrincipal()),
                    ),
                  ),
                  if (isNovo) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onRecusar,
                      icon: const Icon(Icons.close, color: Colors.red, size: 28),
                      tooltip: 'Recusar pedido',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
