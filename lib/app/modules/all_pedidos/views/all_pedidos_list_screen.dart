import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/all_pedidos_cubit.dart';
import '../bloc/all_pedidos_state.dart';
import '../widgets/all_pedido_card_widget.dart';
import '../../home/views/widgets/side_menu.dart';
import '../../../widgets/generic_filter_widget.dart';
import '../../../core/responsive/responsive_scaffold.dart';
import '../../../widgets/custom_app_bar.dart';

class AllPedidosListScreen extends StatefulWidget {
  const AllPedidosListScreen({super.key});

  @override
  State<AllPedidosListScreen> createState() => _AllPedidosListScreenState();
}

class _AllPedidosListScreenState extends State<AllPedidosListScreen> {
  late final AllPedidosCubit _cubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<AllPedidosCubit>();
    _cubit.loadInitialPedidos();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _cubit.loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await _cubit.loadInitialPedidos();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ResponsiveScaffold(
      appBar: CustomAppBar(
        title: 'Todos os Pedidos',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _onRefresh,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      drawer: const SideMenu(isDrawer: true),
      body: BlocConsumer<AllPedidosCubit, AllPedidosState>(
        listener: (context, state) {
          if (state.error != null && state.items.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // ⭐ PRIMEIRO CARREGAMENTO (TELA INTEIRA)
          if (state.isLoading && state.isFirstLoad) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ⭐ ERRO NA PRIMEIRA CARGA
          if (state.error != null && state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDark ? Colors.grey[400] : Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar pedidos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.error!,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _cubit.loadInitialPedidos,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          // ⭐ LISTA PRINCIPAL
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ⭐ FILTRO GENÉRICO
                SliverToBoxAdapter(
                  child: GenericFilterWidget(
                    groups: state.filterGroups,
                    filterCubit: _cubit.filterCubit,
                    onApply: (params) {
                      _cubit.applyFilters(
                        status: params['status']?.toString(),
                        periodo: params['periodo']?.toString(),
                        search: params['search']?.toString(),
                      );
                    },
                    totalItems: state.total,
                    initialFilters: _cubit.currentFilters,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // ⭐ LISTA DE PEDIDOS / LOADING / EMPTY STATE
                if (state.isLoading && !state.isLoadingMore && state.items.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.items.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 80,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum pedido encontrado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ajuste os filtros ou aguarde novos pedidos',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // ⭐ PROGRESS NO FINAL DA LISTA (Apenas para Paginação)
                          if (index == state.items.length) {
                            if (state.isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return const SizedBox(height: 80); // Espaço extra no final
                          }

                          final pedido = state.items[index];
                          return AllPedidoCardWidget(
                            pedido: pedido,
                            onTap: () {
                              context.push(
                                '/all-pedidos/${pedido.id}',
                              );
                            },
                          );
                        },
                        childCount: state.items.length + 1,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
