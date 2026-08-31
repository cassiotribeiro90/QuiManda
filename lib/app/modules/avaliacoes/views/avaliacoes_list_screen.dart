// lib/app/modules/avaliacoes/views/avaliacoes_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/responsive/responsive_scaffold.dart';
import '../../../shared/widgets/star_rating.dart';
import '../bloc/avaliacoes_cubit.dart';
import '../../../widgets/generic_filter_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../models/avaliacao_model.dart';

class AvaliacoesListScreen extends StatefulWidget {
  const AvaliacoesListScreen({super.key});

  @override
  State<AvaliacoesListScreen> createState() => _AvaliacoesListScreenState();
}

class _AvaliacoesListScreenState extends State<AvaliacoesListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AvaliacoesCubit>().carregar();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<AvaliacoesCubit>().state;
      if (state is AvaliacoesLoaded && state.hasMore) {
        context.read<AvaliacoesCubit>().carregarMais();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ResponsiveScaffold(
      appBar: const CustomAppBar(
        title: 'Avaliações',
      ),
      body: BlocConsumer<AvaliacoesCubit, AvaliacoesState>(
        listener: (context, state) {
          if (state is AvaliacoesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AvaliacoesError) {
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
                  const Text(
                    'Erro ao carregar avaliações',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<AvaliacoesCubit>().carregar(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AvaliacoesCubit>().carregar();
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: GenericFilterWidget(
                    groups: (state is AvaliacoesLoaded)
                        ? state.filterGroups
                        : [],
                    onApply: (params) {
                      debugPrint('🔵 [AvaliacoesListScreen] Filtros aplicados: $params');
                      context.read<AvaliacoesCubit>().carregar(
                        status: params['status']?.toString(),
                      );
                    },
                    totalItems: (state is AvaliacoesLoaded) ? state.total : 0,
                    initialFilters: (state is AvaliacoesLoaded)
                        ? state.currentFilters
                        : {},
                  ),
                ),

                if (state is AvaliacoesLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                else if (state is AvaliacoesLoaded && state.avaliacoes.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_border,
                            size: 64,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma avaliação encontrada',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state is AvaliacoesLoaded)
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final avaliacao = state.avaliacoes[index];
                            return _buildAvaliacaoItem(context, avaliacao);
                          },
                          childCount: state.avaliacoes.length,
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

  Widget _buildAvaliacaoItem(BuildContext context, AvaliacaoModel avaliacao) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(avaliacao.status).withValues(alpha: 0.2),
          child: Icon(
            _getStatusIcon(avaliacao.status),
            color: _getStatusColor(avaliacao.status),
          ),
        ),
        title: Row(
          children: [
            // 🔥 Estrelas como ícones (preenchidas e vazias)
            StarRating(
              rating: avaliacao.nota.toDouble(),
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                avaliacao.isProduto
                    ? (avaliacao.produtoNome ?? 'Produto')
                    : 'Pedido #${avaliacao.pedidoCodigo ?? avaliacao.pedidoId ?? 'N/A'}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              avaliacao.comentario?.isNotEmpty == true
                  ? avaliacao.comentario!
                  : 'Sem comentário',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: avaliacao.isPendente ? Colors.black : Colors.grey[600],
                fontWeight: avaliacao.isPendente ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (avaliacao.isProduto && avaliacao.pedidoCodigo != null)
              Text(
                'Pedido #${avaliacao.pedidoCodigo}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            if (avaliacao.isPedido && avaliacao.usuarioNome != null)
              Text(
                'Cliente: ${avaliacao.usuarioNome}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              avaliacao.dataFormatada,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(avaliacao.status).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                avaliacao.statusLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(avaliacao.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          context.push('/avaliacoes/detalhe', extra: avaliacao);
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'aprovado':
        return Colors.green;
      case 'rejeitado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'aprovado':
        return Icons.check_circle;
      case 'rejeitado':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }
}