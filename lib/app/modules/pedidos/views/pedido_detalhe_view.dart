import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/pedido_model.dart';

class PedidoDetalheView extends StatelessWidget {
  final PedidoModel pedido;

  const PedidoDetalheView({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text('Pedido #${pedido.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Cliente', pedido.cliente),
            const Divider(),
            _buildInfoRow('Status', pedido.status),
            const Divider(),
            _buildInfoRow('Valor', currencyFormat.format(pedido.valor)),
            const Divider(),
            _buildInfoRow('Data', dateFormat.format(pedido.data.toLocal())),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // In a real app, update status
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status atualizado!')),
                );
              },
              child: const Text('MARCAR COMO PRONTO'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
