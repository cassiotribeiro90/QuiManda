import 'package:equatable/equatable.dart';
import '../model/produto_model.dart';

abstract class ProdutosState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProdutosInitial extends ProdutosState {}

class ProdutosLoading extends ProdutosState {}

class ProdutosLoaded extends ProdutosState {
  final List<ProdutoModel> produtos;
  ProdutosLoaded(this.produtos);
  @override
  List<Object?> get props => [produtos];
}

class ProdutosError extends ProdutosState {
  final String message;
  ProdutosError(this.message);
  @override
  List<Object?> get props => [message];
}
