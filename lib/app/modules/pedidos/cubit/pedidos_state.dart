// lib/app/modules/pedidos/cubit/pedidos_state.dart
import 'package:equatable/equatable.dart';
import '../model/pedido_model.dart';
import '../../../models/chat_nao_lido.dart';

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
  final bool isLoading;
  final int? updatingPedidoId;
  final List<ChatNaoLido> chatsNaoLidos;
  final bool isTtsMuted;
  final List<PedidoModel> pedidosComNaoLidas;
  final bool isTtsLooping;
  final int pendingAlertsCount;

  const PedidosLoaded({
    required this.grupos,
    this.totalPedidos = 0,
    this.isLoading = false,
    this.updatingPedidoId,
    this.chatsNaoLidos = const [],
    this.isTtsMuted = false,
    this.pedidosComNaoLidas = const [],
    this.isTtsLooping = false,
    this.pendingAlertsCount = 0,
  });

  PedidosLoaded copyWith({
    List<GrupoPedidos>? grupos,
    int? totalPedidos,
    bool? isLoading,
    int? updatingPedidoId,
    List<ChatNaoLido>? chatsNaoLidos,
    bool? isTtsMuted,
    List<PedidoModel>? pedidosComNaoLidas,
    bool? isTtsLooping,
    int? pendingAlertsCount,
  }) {
    return PedidosLoaded(
      grupos: grupos ?? this.grupos,
      totalPedidos: totalPedidos ?? this.totalPedidos,
      isLoading: isLoading ?? this.isLoading,
      updatingPedidoId: updatingPedidoId ?? this.updatingPedidoId,
      chatsNaoLidos: chatsNaoLidos ?? this.chatsNaoLidos,
      isTtsMuted: isTtsMuted ?? this.isTtsMuted,
      pedidosComNaoLidas: pedidosComNaoLidas ?? this.pedidosComNaoLidas,
      isTtsLooping: isTtsLooping ?? this.isTtsLooping,
      pendingAlertsCount: pendingAlertsCount ?? this.pendingAlertsCount,
    );
  }

  bool get hasPedidos => grupos.any((g) => g.itens.isNotEmpty);
  
  bool isUpdating(int pedidoId) => updatingPedidoId == pedidoId;

  @override
  List<Object?> get props => [
        grupos,
        totalPedidos,
        isLoading,
        updatingPedidoId,
        chatsNaoLidos,
        isTtsMuted,
        pedidosComNaoLidas,
        isTtsLooping,
        pendingAlertsCount,
      ];
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
