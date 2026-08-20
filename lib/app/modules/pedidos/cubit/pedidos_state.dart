// lib/app/modules/pedidos/cubit/pedidos_state.dart
import 'package:equatable/equatable.dart';
import '../model/pedido_model.dart';

class GrupoPedidos extends Equatable {
  final String status;
  final String label;
  final int total;
  final List<PedidoModel> itens;

  const GrupoPedidos({
    required this.status,
    required this.label,
    required this.total,
    required this.itens,
  });

  factory GrupoPedidos.fromJson(Map<String, dynamic> json) {
    return GrupoPedidos(
      status: json['status'] ?? '',
      label: json['label'] ?? '',
      total: json['total'] ?? 0,
      itens: (json['itens'] as List?)
          ?.map((e) => PedidoModel.fromJson(e))
          .toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [status, label, total, itens];
}

abstract class PedidosState extends Equatable {
  const PedidosState();
  @override
  List<Object?> get props => [];
}

class PedidosInitial extends PedidosState {}

class PedidosLoading extends PedidosState {}

class PedidosLoaded extends PedidosState {
  final List<GrupoPedidos> grupos;
  final int totalPedidos;
  final bool isLoading; // 🔥 Indica refresh em background

  const PedidosLoaded({
    required this.grupos,
    this.totalPedidos = 0,
    this.isLoading = false,
  });

  PedidosLoaded copyWith({
    List<GrupoPedidos>? grupos,
    int? totalPedidos,
    bool? isLoading,
  }) {
    return PedidosLoaded(
      grupos: grupos ?? this.grupos,
      totalPedidos: totalPedidos ?? this.totalPedidos,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get hasPedidos => grupos.any((g) => g.itens.isNotEmpty);

  @override
  List<Object?> get props => [grupos, totalPedidos, isLoading];
}

class PedidosError extends PedidosState {
  final String message;
  const PedidosError(this.message);
  @override
  List<Object?> get props => [message];
}

class PedidoActionError extends PedidosState {
  final String message;
  const PedidoActionError(this.message);
  @override
  List<Object?> get props => [message];
}
