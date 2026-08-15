import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int totalPedidos;
  final double faturamento;
  final int produtosAtivos;

  DashboardLoaded({
    required this.totalPedidos,
    required this.faturamento,
    required this.produtosAtivos,
  });

  @override
  List<Object?> get props => [totalPedidos, faturamento, produtosAtivos];
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
