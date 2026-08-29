import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/responsive/responsive_scaffold.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/chat_item_widget.dart';
import '../../../widgets/generic_filter_widget.dart';
import '../../../widgets/custom_app_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    debugPrint('💬 [ChatPage] initState');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatBloc>().add(const ChatLoadChats(reset: true));
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
      final state = context.read<ChatBloc>().state;
      if (state.hasMore && !state.isLoadingMore) {
        context.read<ChatBloc>().add(const ChatLoadMore());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ResponsiveScaffold(
      appBar: const CustomAppBar(
        title: 'Minhas Conversas',
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
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
          // Erro na primeira carga
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
                  const Text('Erro ao carregar conversas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(state.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<ChatBloc>().add(const ChatLoadChats(reset: true)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ChatBloc>().add(const ChatRefresh());
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 🔥 Filtros QuiGestor - Sempre visíveis, mesmo carregando
                SliverToBoxAdapter(
                  child: GenericFilterWidget(
                    groups: state.filterGroups ?? [],
                    onApply: (params) {
                      debugPrint('🔵 [ChatPage] Filtros aplicados: $params');
                      context.read<ChatBloc>().add(ChatFiltersApplied(params));
                    },
                    totalItems: state.total,
                    initialFilters: state.currentFilters,
                  ),
                ),

                // 🔥 AREA DA LISTA / LOADING
                if (state.isLoading && state.items.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                else if (state.items.isEmpty && state.hasLoaded)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_outlined,
                            size: 64,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma conversa encontrada',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == state.items.length) {
                            if (state.isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return const SizedBox.shrink();
                          }
                          return ChatItemWidget(
                            chat: state.items[index],
                            onTap: () => context.read<ChatBloc>().add(const ChatLoadChats(reset: true)),
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
