import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/pedidos_cubit.dart';
import '../cubit/pedidos_state.dart';
import '../widgets/pedido_status_section.dart';
import '../widgets/pedido_empty_widget.dart';
import '../widgets/chat_card_widget.dart';
import '../../../core/responsive/responsive_scaffold.dart';
import '../../../widgets/custom_app_bar.dart';


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
      appBar: CustomAppBar(
        titleWidget: Row(
          children: [
            const Text('Pedidos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        actions: [
          // 🔥 INDICADOR DE LOOP TTS (NOVO)
          BlocBuilder<PedidosCubit, PedidosState>(
            builder: (context, state) {
              if (state is PedidosLoaded && state.isTtsLooping && state.pendingAlertsCount > 0) {
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
                        '${state.pendingAlertsCount}',
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
              final bool isMuted = state is PedidosLoaded 
                  ? state.isTtsMuted 
                  : context.read<PedidosCubit>().isTtsMuted;

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
            final chatCards = state.chatsNaoLidos
                .map((chat) => ChatCardWidget(
                      chat: chat,
                      onTap: () => _abrirChatGenerico(context, chat.chatId),
                    ))
                .toList();

            if (state.totalPedidos == 0 && state.chatsNaoLidos.isEmpty) {
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
                children: [
                  ...chatCards,
                  ...state.grupos.map((grupo) => PedidoStatusSection(
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
                      )),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _abrirChatGenerico(BuildContext context, int chatId) {
    debugPrint('💬 [NAVIGATION] Abrindo chat genérico ID: $chatId');
    
    // 🔥 Usando GoRouter via context.pushNamed para compatibilidade com as rotas definidas
    GoRouter.of(context).pushNamed(
      'chat-detalhe',
      extra: {'chatId': chatId, 'isGeneric': true},
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
