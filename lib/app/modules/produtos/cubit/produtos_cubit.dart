import 'package:flutter_bloc/flutter_bloc.dart';
import 'produtos_state.dart';
import '../service/produtos_service.dart';
import '../model/produto_model.dart';

class ProdutosCubit extends Cubit<ProdutosState> {
  final ProdutosService _service;

  ProdutosCubit(this._service) : super(ProdutosInitial());

  Future<void> loadProdutos() async {
    emit(ProdutosLoading());
    try {
      final produtos = await _service.getProdutos();
      emit(ProdutosLoaded(produtos));
    } catch (e) {
      emit(ProdutosError('Falha ao carregar produtos: ${e.toString()}'));
    }
  }

  Future<void> saveProduto(ProdutoModel produto) async {
    emit(ProdutosLoading());
    try {
      await _service.saveProduto(produto);
      await loadProdutos();
    } catch (e) {
      emit(ProdutosError('Falha ao salvar produto: ${e.toString()}'));
    }
  }
}
