import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/pedidos_cubit.dart';
import '../cubit/pedidos_state.dart';
import 'pedido_detalhe_view.dart';

class PedidosListView extends StatefulWidget {
  const PedidosListView({super.key});

  @override
  State<PedidosListView> createState() => _PedidosListViewState();
}

class _PedidosListViewState extends State<PedidosListView> {
  @override
  void initState() {
    super.initState();
    context.read<PedidosCubit>().loadPedidos();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: BlocBuilder<PedidosCubit, PedidosState>(
        builder: (context, state) {
          if (state is PedidosLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PedidosError) {
            return Center(child: Text(state.message));
          }
          if (state is PedidosLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<PedidosCubit>().loadPedidos(),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: state.pedidos.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final pedido = state.pedidos[index];
                  return ListTile(
                    title: Text('Pedido #${pedido.id}'),
                    subtitle: Text('${pedido.cliente} - ${pedido.status}'),
                    trailing: Text(
                      currencyFormat.format(pedido.valor),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PedidoDetalheView(pedido: pedido),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
