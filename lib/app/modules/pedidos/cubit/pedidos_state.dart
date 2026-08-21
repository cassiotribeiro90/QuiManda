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
      status: json['status']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      total: (json['total'] as num?)?.toInt() ?? 0,
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
  final int? updatingPedidoId; // 🔥 NOVO: ID do pedido sendo atualizado

  const PedidosLoaded({
    required this.grupos,
    this.totalPedidos = 0,
    this.isLoading = false,
    this.updatingPedidoId,
  });

  PedidosLoaded copyWith({
    List<GrupoPedidos>? grupos,
    int? totalPedidos,
    bool? isLoading,
    int? updatingPedidoId,
  }) {
    return PedidosLoaded(
      grupos: grupos ?? this.grupos,
      totalPedidos: totalPedidos ?? this.totalPedidos,
      isLoading: isLoading ?? this.isLoading,
      updatingPedidoId: updatingPedidoId ?? this.updatingPedidoId,
    );
  }

  bool get hasPedidos => grupos.any((g) => g.itens.isNotEmpty);
  
  // 🔥 Verifica se um pedido específico está sendo atualizado
  bool isUpdating(int pedidoId) => updatingPedidoId == pedidoId;

  @override
  List<Object?> get props => [grupos, totalPedidos, isLoading, updatingPedidoId];
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
