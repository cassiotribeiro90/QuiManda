import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/produtos_cubit.dart';
import '../cubit/produtos_state.dart';
import 'produto_form_view.dart';

import '../../home/views/home_view.dart';

class ProdutosListView extends StatefulWidget {
  const ProdutosListView({super.key});

  @override
  State<ProdutosListView> createState() => _ProdutosListViewState();
}

class _ProdutosListViewState extends State<ProdutosListView> {
  @override
  void initState() {
    super.initState();
    context.read<ProdutosCubit>().loadProdutos();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        leading: LayoutBuilder(
          builder: (context, constraints) {
            if (MediaQuery.of(context).size.width < 900) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => HomeView.scaffoldKey.currentState?.openDrawer(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProdutosCubit>().loadProdutos(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProdutoFormView()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProdutosCubit, ProdutosState>(
        builder: (context, state) {
          if (state is ProdutosLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProdutosError) {
            return Center(child: Text(state.message));
          }
          if (state is ProdutosLoaded) {
            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () => context.read<ProdutosCubit>().loadProdutos(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.produtos.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final produto = state.produtos[index];
                      return ListTile(
                        title: Text(produto.nome),
                        subtitle: Text(produto.descricao),
                        trailing: Text(
                          currencyFormat.format(produto.preco),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProdutoFormView(produto: produto),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProdutoFormView()),
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
