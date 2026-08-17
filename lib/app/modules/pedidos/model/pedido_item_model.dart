// lib/app/modules/pedidos/model/pedido_item_model.dart
import 'package:equatable/equatable.dart';

class PedidoItemModel extends Equatable {
  final String nome;
  final int quantidade;
  final double precoUnitario;
  final double total;

  const PedidoItemModel({
    required this.nome,
    required this.quantidade,
    required this.precoUnitario,
    required this.total,
  });

  factory PedidoItemModel.fromJson(Map<String, dynamic> json) {
    return PedidoItemModel(
      nome: json['nome']?.toString() ?? '',
      quantidade: (json['quantidade'] as num?)?.toInt() ?? 0,
      precoUnitario: (json['preco_unitario'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'quantidade': quantidade,
    'preco_unitario': precoUnitario,
    'total': total,
  };

  @override
  List<Object?> get props => [nome, quantidade, precoUnitario, total];
}
