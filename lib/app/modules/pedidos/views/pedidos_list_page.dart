import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/pedidos_cubit.dart';
import '../cubit/pedidos_state.dart';
import '../model/pedido_model.dart';
import '../widgets/pedido_status_section.dart';
import '../widgets/pedido_empty_widget.dart';
import '../widgets/status_badge_widget.dart';
import '../../../core/responsive/responsive_scaffold.dart';

import '../../home/views/home_view.dart';

class PedidosListPage extends StatefulWidget {
  const PedidosListPage({super.key});

  @override
  State<PedidosListPage> createState() => _PedidosListPageState();
}

class _PedidosListPageState extends State<PedidosListPage> with WidgetsBindingObserver {
  Timer? _timer;
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    debugPrint('📋 [PEDIDOS] Inicializando listagem de pedidos');
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarPedidos();
    });

    _iniciarTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔄 [PEDIDOS] App retomado - executando refresh silencioso');
      _refreshSilencioso();
    }
  }

  void _iniciarTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && !_isRefreshing) {
        _refreshSilencioso();
      }
    });
  }

  void _carregarPedidos() {
    debugPrint('🔄 [PEDIDOS] Solicitando carga de pedidos ativos');
    context.read<PedidosCubit>().carregarPedidosAtivos();
  }

  Future<void> _refreshSilencioso() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    debugPrint('🔄 [PEDIDOS] Executando auto-update silencioso');
    await context.read<PedidosCubit>().refreshSilencioso();
    if (mounted) _isRefreshing = false;
  }

  Future<void> _onRefresh() async {
    await context.read<PedidosCubit>().refresh();
  }

  void _onManualRefresh() {
    if (_isRefreshing) return;
    _isRefreshing = true;
    context.read<PedidosCubit>().refresh().then((_) {
      if (mounted) _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Text('Pedidos', style: TextStyle(color: Colors.white)),
            const SizedBox(width: 8),
            BlocBuilder<PedidosCubit, PedidosState>(
              builder: (context, state) {
                if (state is PedidosLoaded && state.totalPedidos > 0) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.totalPedidos}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        leading: MediaQuery.of(context).size.width < 900
            ? IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => HomeView.scaffoldKey.currentState?.openDrawer(),
        )
            : null,
        actions: [
          // 🔥 INDICADOR DE LOOP
          BlocBuilder<PedidosCubit, PedidosState>(
            builder: (context, state) {
              final isLooping = context.read<PedidosCubit>().isTtsLooping;
              final pendingCount = context.read<PedidosCubit>().pendingAlertsCount;

              if (isLooping && pendingCount > 0) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // 🔥 Botão Mudo
          BlocBuilder<PedidosCubit, PedidosState>(
            builder: (context, state) {
              final isMuted = context.read<PedidosCubit>().isTtsMuted;
              return IconButton(
                icon: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                ),
                tooltip: isMuted ? 'Ativar som' : 'Desativar som',
                onPressed: () {
                  context.read<PedidosCubit>().registerUserInteraction();
                  context.read<PedidosCubit>().toggleTtsMute();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isMuted ? '🔊 Som ativado' : '🔇 Som desativado'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: isMuted ? Colors.green : Colors.red,
                    ),
                  );
                },
              );
            },
          ),
          // 🔥 Botão de refresh
          BlocBuilder<PedidosCubit, PedidosState>(
            builder: (context, state) {
              if (state is PedidosLoaded && state.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _isRefreshing ? null : _onManualRefresh,
                tooltip: 'Atualizar',
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<PedidosCubit, PedidosState>(
        listener: (context, state) {
          if (state is PedidoActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PedidosLoading && state is! PedidosLoaded) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando pedidos...'),
                ],
              ),
            );
          }

          if (state is PedidosError && state is! PedidosLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar pedidos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onManualRefresh,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is PedidosLoaded) {
            if (state.totalPedidos == 0) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: const SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: PedidoEmptyWidget(),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                children: state.grupos.map((grupo) => PedidoStatusSection(
                  key: ValueKey('section_${grupo.status}'),
                  status: grupo.status,
                  label: grupo.label,
                  total: grupo.total,
                  pedidos: grupo.itens,
                  updatingPedidoId: state.updatingPedidoId,
                  onAceitar: (id) => context.read<PedidosCubit>().aceitarPedido(id),
                  onRecusar: (id) => _mostrarMotivoRecusa(context, id),
                  onAtualizarStatus: (id, novoStatus) =>
                      context.read<PedidosCubit>().atualizarStatus(id, novoStatus),
                  onCardTap: (pedido) => _abrirDetalhes(context, pedido),
                )).toList(),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _abrirDetalhes(BuildContext context, PedidoModel pedido) {
    debugPrint('📦 [UI] Abrindo detalhes do pedido #${pedido.codigo ?? pedido.id}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final trocoPara = pedido.trocoPara;
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pedido #${pedido.codigo ?? pedido.id}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  StatusBadgeWidget(status: pedido.status),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Cliente', pedido.clienteNome ?? 'N/A'),
              _buildInfoRow('Telefone', pedido.clienteTelefone ?? 'N/A'),
              const SizedBox(height: 12),
              _buildInfoRow('Subtotal', 'R\$ ${pedido.subtotal?.toStringAsFixed(2) ?? '0,00'}'),
              _buildInfoRow('Taxa entrega', 'R\$ ${pedido.taxaEntrega?.toStringAsFixed(2) ?? '0,00'}'),
              _buildInfoRow('Total', 'R\$ ${pedido.total.toStringAsFixed(2)}', isBold: true),
              const SizedBox(height: 12),
              _buildInfoRow('Forma pagamento', pedido.formaPagamento ?? 'N/A'),
              if (trocoPara != null && trocoPara > 0)
                _buildInfoRow('Troco para', 'R\$ ${trocoPara.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              if (pedido.itens.isNotEmpty) ...[
                const Text(
                  'Itens:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: pedido.itens.length,
                    itemBuilder: (context, index) {
                      final item = pedido.itens[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('${item.quantidade}x ${item.nome} - R\$ ${item.precoUnitario.toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ),
              ],
              if (pedido.observacoes != null && pedido.observacoes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Observações: ${pedido.observacoes}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('⬅️ [NAVIGATION] Fechando detalhes do pedido');
                    Navigator.pop(context);
                  },
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 16 : 14,
                color: isBold ? Colors.green : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMotivoRecusa(BuildContext context, int id) {
    final motivoController = TextEditingController();
    final codigos = [
      'item_indisponivel',
      'fora_area',
      'volume_alto',
      'outro'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Motivo da recusa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: codigos.map((codigo) {
                  return ChoiceChip(
                    label: Text(_getMotivoLabel(codigo)),
                    selected: false,
                    onSelected: (selected) {
                      motivoController.text = codigo;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: motivoController,
                decoration: const InputDecoration(
                  labelText: 'Outro motivo (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        debugPrint('⬅️ [NAVIGATION] Cancelando recusa de pedido');
                        Navigator.pop(context);
                      },
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        debugPrint('❌ [PEDIDOS] Confirmando recusa de ID: $id');
                        Navigator.pop(context);
                        context.read<PedidosCubit>().recusarPedido(
                          id,
                          motivo: motivoController.text.isNotEmpty ? motivoController.text : null,
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Recusar'),
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

  String _getMotivoLabel(String codigo) {
    switch (codigo) {
      case 'item_indisponivel': return 'Item indisponível';
      case 'fora_area': return 'Fora da área';
      case 'volume_alto': return 'Volume alto';
      default: return 'Outro';
    }
  }
}
