import '../model/produto_model.dart';
import '../repository/produtos_repository.dart';

class ProdutosService {
  final ProdutosRepository _repository;
  ProdutosService(this._repository);

  Future<List<ProdutoModel>> getProdutos() async {
    final data = await _repository.getProdutos();
    return data.map((json) => ProdutoModel.fromJson(json)).toList();
  }

  Future<void> saveProduto(ProdutoModel produto) async {
    // In a real app, convert model to JSON and send to repository
    await _repository.saveProduto({
      'nome': produto.nome,
      'descricao': produto.descricao,
      'preco': produto.preco,
      'disponivel': produto.disponivel,
    });
  }
}
