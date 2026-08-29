import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/responsive/responsive_scaffold.dart';
import '../../../navigation/navigation_cubit.dart';
import '../bloc/cardapio_cubit.dart';
import '../bloc/cardapio_state.dart';
import '../models/produto_model.dart';
import 'widgets/produto_card.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/custom_app_bar.dart';

class CardapioPage extends StatelessWidget {
  const CardapioPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🍽️ [ROUTER] Construindo CardapioPage (Listagem)');
    return const CardapioListView();
  }
}

class CardapioListView extends StatefulWidget {
  const CardapioListView({super.key});

  @override
  State<CardapioListView> createState() => _CardapioListViewState();
}

class _CardapioListViewState extends State<CardapioListView> {
  @override
  void initState() {
    super.initState();
    debugPrint('🎬 [CARDAPIO] Inicializando listagem de produtos');
    context.read<CardapioCubit>().carregarProdutos();
  }

  @override
  Widget build(BuildContext context) {
    context.read<NavigationCubit>();
    
    return ResponsiveScaffold(
      maxWidth: 1000,
      appBar: CustomAppBar(
        title: 'Meu Cardápio',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              debugPrint('🔄 [UI] Solicitando recarga do cardápio');
              context.read<CardapioCubit>().carregarProdutos();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('NOVO PRODUTO'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<CardapioCubit, CardapioState>(
        listener: (context, state) {
          debugPrint('📢 [CARDAPIO] Mudança de estado: ${state.runtimeType}');
          if (state is CardapioOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          }
          if (state is CardapioError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if ((state is CardapioLoading || state is CardapioInitial) && 
              context.read<CardapioCubit>().produtosAgrupados.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CardapioError && state is! CardapioLoaded) {
             return _buildErrorState(context, state.message);
          }

          final grupos = context.read<CardapioCubit>().produtosAgrupados;
          final keys = grupos.keys.toList();

          if (keys.isEmpty && state is! CardapioOperationLoading) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => context.read<CardapioCubit>().carregarProdutos(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: keys.length + grupos.values.fold(0, (sum, list) => sum + list.length),
              itemBuilder: (context, index) {
                int accumulated = 0;
                for (var key in keys) {
                  final produtos = grupos[key]!;
                  if (index == accumulated) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(8, 32, 16, 12),
                      child: Text(
                        key.toUpperCase(),
                        style: AppTextStyles.label,
                      ),
                    );
                  }
                  
                  if (index < accumulated + 1 + produtos.length) {
                    final produto = produtos[index - accumulated - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ProdutoCard(
                        produto: produto,
                        onEdit: () => _abrirFormulario(produto),
                        onDelete: () => _confirmarExclusao(context, produto),
                        onToggle: (val) {
                          debugPrint('🔄 [CARDAPIO] Alternando disponibilidade de ${produto.nome} para $val');
                          context.read<CardapioCubit>().alternarDisponibilidade(produto.id!, val);
                        },
                      ),
                    );
                  }
                  accumulated += produtos.length + 1;
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Seu cardápio está vazio',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 8),
          const Text('Comece adicionando seu primeiro produto!'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _abrirFormulario(),
            child: const Text('ADICIONAR PRODUTO'),
          )
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Não foi possível carregar o cardápio',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<CardapioCubit>().carregarProdutos(),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  void _abrirFormulario([ProdutoModel? produto]) {
    debugPrint('📤 [NAVIGATION] Abrindo formulário de produto. Edição: ${produto != null}');
    context.read<NavigationCubit>().goToFormularioProduto(produto: produto);
  }

  void _confirmarExclusao(BuildContext context, ProdutoModel produto) {
    debugPrint('⚠️ [UI] Confirmando exclusão de produto: ${produto.nome}');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir Produto'),
        content: Text('Deseja realmente excluir "${produto.nome}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('⬅️ [NAVIGATION] Cancelando exclusão');
              Navigator.pop(dialogContext);
            },
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              debugPrint('❌ [CARDAPIO] Confirmando exclusão de ID: ${produto.id}');
              Navigator.pop(dialogContext);
              await context.read<CardapioCubit>().deleteProduto(produto.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );
  }
}
