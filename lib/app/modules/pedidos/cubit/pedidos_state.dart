import 'package:equatable/equatable.dart';
import '../model/pedido_model.dart';

abstract class PedidosState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PedidosInitial extends PedidosState {}

class PedidosLoading extends PedidosState {}

class PedidosLoaded extends PedidosState {
  final List<PedidoModel> pedidos;
  PedidosLoaded(this.pedidos);
  @override
  List<Object?> get props => [pedidos];
}

class PedidosError extends PedidosState {
  final String message;
  PedidosError(this.message);
  @override
  List<Object?> get props => [message];
}
