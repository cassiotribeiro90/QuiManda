import '../models/produto_model.dart';
import '../models/categoria.dart';
import '../models/subcategoria.dart';

abstract class CardapioState {
  const CardapioState();
}

class CardapioInitial extends CardapioState {}

class CardapioLoading extends CardapioState {}

class CardapioOperationLoading extends CardapioState {}

class CardapioOperationSuccess extends CardapioState {
  final String message;
  final List<ProdutoModel>? produtos;
  CardapioOperationSuccess(this.message, {this.produtos});
}

class CardapioLoaded extends CardapioState {
  final List<ProdutoModel> produtos;
  CardapioLoaded(this.produtos);
}

class CardapioError extends CardapioState {
  final String message;
  CardapioError(this.message);
}

class CardapioFormLoaded extends CardapioState {
  final List<Categoria> categorias;
  final List<Subcategoria> subcategorias;
  final ProdutoModel? produto;
  final List<ProdutoModel>? produtos; // List of products to keep the background list visible
  
  const CardapioFormLoaded({
    required this.categorias, 
    this.subcategorias = const [], 
    this.produto,
    this.produtos,
  });

  CardapioFormLoaded copyWith({
    List<Categoria>? categorias,
    List<Subcategoria>? subcategorias,
    ProdutoModel? produto,
    List<ProdutoModel>? produtos,
  }) {
    return CardapioFormLoaded(
      categorias: categorias ?? this.categorias,
      subcategorias: subcategorias ?? this.subcategorias,
      produto: produto ?? this.produto,
      produtos: produtos ?? this.produtos,
    );
  }
}
