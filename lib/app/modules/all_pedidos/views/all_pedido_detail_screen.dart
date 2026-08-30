import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/all_pedidos_cubit.dart';
import '../models/all_pedido_model.dart';

class AllPedidoDetailScreen extends StatefulWidget {
  final int pedidoId;

  const AllPedidoDetailScreen({
    super.key,
    required this.pedidoId,
  });

  @override
  State<AllPedidoDetailScreen> createState() => _AllPedidoDetailScreenState();
}

class _AllPedidoDetailScreenState extends State<AllPedidoDetailScreen> {
  late final AllPedidosCubit _cubit;
  AllPedido? _pedido;
  bool _loading = true;
  String? _error;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<AllPedidosCubit>();
    _loadPedido();
  }

  Future<void> _loadPedido() async {
    setState(() => _loading = true);
    try {
      final pedido = await _cubit.fetchPedidoDetail(widget.pedidoId);
      setState(() {
        _pedido = pedido;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (_updating) return;
    setState(() => _updating = true);

    final success = await _cubit.updatePedidoStatus(
      widget.pedidoId,
      newStatus,
    );

    if (mounted) {
      setState(() => _updating = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadPedido();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao atualizar status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes do Pedido'),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _pedido == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes do Pedido'),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                'Erro ao carregar pedido',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Pedido não encontrado',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPedido,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final pedido = _pedido!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido ${pedido.codigo}'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: 'Voltar',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPedido,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⭐ HEADER - Código e Status
            _buildHeader(pedido, isDark),

            const SizedBox(height: 16),

            // ⭐ TIMELINE - Status do Pedido
            _buildTimeline(pedido, isDark),

            const SizedBox(height: 20),

            // ⭐ AÇÕES - Botões de Status
            _buildStatusActions(pedido, isDark),

            const SizedBox(height: 20),

            // ⭐ INFORMAÇÕES DO CLIENTE
            _buildClienteSection(pedido, isDark),

            const SizedBox(height: 16),

            // ⭐ INFORMAÇÕES DO ENDEREÇO
            _buildEnderecoSection(pedido, isDark),

            const SizedBox(height: 16),

            // ⭐ ITENS DO PEDIDO
            _buildItensSection(pedido, isDark),

            const SizedBox(height: 16),

            // ⭐ RESUMO DOS VALORES
            _buildValoresSection(pedido, isDark),

            const SizedBox(height: 16),

            // ⭐ PAGAMENTO
            _buildPagamentoSection(pedido, isDark),

            const SizedBox(height: 16),

            // ⭐ OBSERVAÇÕES
            if (pedido.observacoes != null && pedido.observacoes!.isNotEmpty)
              _buildObservacoesSection(pedido, isDark),

            const SizedBox(height: 16),

            // ⭐ INFORMAÇÕES ADICIONAIS
            _buildInformacoesAdicionais(pedido, isDark),

            // ⭐ BOTÃO CANCELAR
            if (pedido.isAtivo) ...[
              const SizedBox(height: 24),
              _buildCancelButton(pedido, isDark),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ==================== WIDGETS ====================

  Widget _buildHeader(AllPedido pedido, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: pedido.statusColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: pedido.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              pedido.statusIcon,
              color: pedido.statusColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pedido.codigo,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: pedido.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: pedido.statusColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        pedido.statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: pedido.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      pedido.clienteNome ?? 'Cliente não informado',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      pedido.dataFormatada,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(AllPedido pedido, bool isDark) {
    final steps = [
      {'status': 'novo', 'label': 'Pedido Criado', 'icon': Icons.receipt, 'date': pedido.criadoEm},
      {'status': 'confirmado', 'label': 'Confirmado', 'icon': Icons.check_circle, 'date': pedido.dataConfirmacao},
      {'status': 'preparando', 'label': 'Em Preparo', 'icon': Icons.kitchen, 'date': pedido.dataPreparo},
      {'status': 'pronto', 'label': 'Pronto', 'icon': Icons.done_all, 'date': pedido.dataPreparo},
      {'status': 'saiu', 'label': 'Saiu para Entrega', 'icon': Icons.delivery_dining, 'date': pedido.dataSaida},
      {'status': 'entregue', 'label': 'Entregue', 'icon': Icons.home, 'date': pedido.dataEntrega},
    ];

    // Filtra apenas os passos relevantes
    final activeSteps = steps.where((s) => s['date'] != null).toList();

    if (activeSteps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status do Pedido',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...activeSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == activeSteps.length - 1;
            final isActive = step['status'] == pedido.status;
            final isCompleted = activeSteps
                .take(index)
                .any((s) => s['status'] == pedido.status);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive
                            ? pedido.statusColor
                            : isCompleted
                                ? Colors.green
                                : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 32,
                        color: isCompleted
                            ? Colors.green
                            : Colors.grey.shade300,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['label'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive
                                ? pedido.statusColor
                                : isCompleted
                                    ? Colors.green
                                    : isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[400],
                          ),
                        ),
                        if (step['date'] != null)
                          Text(
                            _formatDateTime(step['date'] as DateTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[500] : Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatusActions(AllPedido pedido, bool isDark) {
    final availableStatus = ['confirmado', 'preparando', 'pronto', 'saiu', 'entregue'];
    final currentIndex = availableStatus.indexOf(pedido.status);
    final nextStatuses = currentIndex >= 0
        ? availableStatus.sublist(currentIndex + 1)
        : [];

    if (nextStatuses.isEmpty || pedido.isCancelado) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: nextStatuses.map((status) {
              final label = AllPedido.getStatusLabel(status);
              final color = AllPedido.getStatusColor(status);
              return _buildActionChip(
                label: label,
                color: color,
                onTap: () => _updateStatus(status),
                isLoading: _updating,
                isDark: isDark,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isLoading,
    required bool isDark,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClienteSection(AllPedido pedido, bool isDark) {
    return _buildInfoCard(
      title: 'Cliente',
      icon: Icons.person,
      isDark: isDark,
      children: [
        _buildInfoRow('Nome', pedido.clienteNome ?? '--', isDark),
        if (pedido.clienteTelefone != null)
          _buildInfoRow('Telefone', pedido.clienteTelefone!, isDark),
      ],
    );
  }

  Widget _buildEnderecoSection(AllPedido pedido, bool isDark) {
    return _buildInfoCard(
      title: 'Endereço de Entrega',
      icon: Icons.location_on,
      isDark: isDark,
      children: [
        _buildInfoRow('Endereço', pedido.enderecoCompleto, isDark),
        if (pedido.distanciaKm != null)
          _buildInfoRow('Distância', pedido.distanciaFormatada, isDark),
        if (pedido.tempoEsperaMin != null)
          _buildInfoRow('Tempo estimado', '${pedido.tempoEsperaMin} min', isDark),
      ],
    );
  }

  Widget _buildItensSection(AllPedido pedido, bool isDark) {
    if (pedido.itens == null || pedido.itens!.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildInfoCard(
      title: 'Itens do Pedido',
      icon: Icons.shopping_bag,
      isDark: isDark,
      children: [
        ...pedido.itens!.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${item.quantidade}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nome,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (item.observacoes != null)
                          Text(
                            item.observacoes!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    item.totalFormatado,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            )),
        const Divider(),
        _buildInfoRow('Subtotal', pedido.subtotalFormatado, isDark),
        _buildInfoRow('Taxa de entrega', pedido.taxaEntregaFormatada, isDark),
        if (pedido.desconto > 0)
          _buildInfoRow('Desconto', '-${pedido.descontoFormatada}', isDark,
              isNegative: true),
        _buildInfoRow('Total', pedido.totalFormatado, isDark, isBold: true),
      ],
    );
  }

  Widget _buildValoresSection(AllPedido pedido, bool isDark) {
    return _buildInfoCard(
      title: 'Resumo Financeiro',
      icon: Icons.attach_money,
      isDark: isDark,
      children: [
        _buildInfoRow('Subtotal', pedido.subtotalFormatado, isDark),
        _buildInfoRow('Taxa de entrega', pedido.taxaEntregaFormatada, isDark),
        if (pedido.desconto > 0)
          _buildInfoRow('Desconto', '-${pedido.descontoFormatada}', isDark,
              isNegative: true),
        const Divider(),
        _buildInfoRow('Total', pedido.totalFormatado, isDark, isBold: true),
      ],
    );
  }

  Widget _buildPagamentoSection(AllPedido pedido, bool isDark) {
    return _buildInfoCard(
      title: 'Pagamento',
      icon: Icons.credit_card,
      isDark: isDark,
      children: [
        _buildInfoRow('Forma', pedido.formaPagamentoLabel, isDark),
        _buildInfoRow(
          'Status',
          pedido.pagamentoStatusLabel,
          isDark,
          color: pedido.pagamentoStatusColor,
        ),
        if (pedido.trocoPara != null)
          _buildInfoRow('Troco para', pedido.trocoParaFormatado, isDark),
      ],
    );
  }

  Widget _buildObservacoesSection(AllPedido pedido, bool isDark) {
    return _buildInfoCard(
      title: 'Observações',
      icon: Icons.note,
      isDark: isDark,
      children: [
        Text(
          pedido.observacoes!,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildInformacoesAdicionais(AllPedido pedido, bool isDark) {
    final items = <Widget>[];

    if (pedido.canceladoPor != null) {
      items.add(_buildInfoRow(
        'Cancelado por',
        pedido.canceladoPorLabel,
        isDark,
      ));
    }
    if (pedido.canceladoMotivo != null) {
      items.add(_buildInfoRow(
        'Motivo do cancelamento',
        pedido.canceladoMotivo!,
        isDark,
      ));
    }
    if (pedido.tempoRealMin != null) {
      items.add(_buildInfoRow(
        'Tempo real de preparo',
        '${pedido.tempoRealMin} min',
        isDark,
      ));
    }
    if (pedido.entregadorLat != null) {
      items.add(_buildInfoRow(
        'Localização do entregador',
        '${pedido.entregadorLat!.toStringAsFixed(6)}, ${pedido.entregadorLng!.toStringAsFixed(6)}',
        isDark,
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return _buildInfoCard(
      title: 'Informações Adicionais',
      icon: Icons.info_outline,
      isDark: isDark,
      children: items,
    );
  }

  Widget _buildCancelButton(AllPedido pedido, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _updating ? null : () => _showCancelDialog(pedido),
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('Cancelar Pedido'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(AllPedido pedido) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Pedido'),
        content: const Text(
          'Tem certeza que deseja cancelar este pedido? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus('cancelado');
            },
            child: const Text(
              'Sim, cancelar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== AUXILIARES ====================

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    bool isDark, {
    Color? color,
    bool isBold = false,
    bool isNegative = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color ??
                    (isNegative
                        ? Colors.red
                        : isDark
                            ? Colors.white
                            : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
