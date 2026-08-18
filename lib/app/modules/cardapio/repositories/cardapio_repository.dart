import '../models/produto_model.dart';
import '../models/categoria.dart';
import '../models/subcategoria.dart';
import '../services/cardapio_service.dart';

class CardapioRepository {
  final CardapioService service;

  CardapioRepository(this.service);

  Future<List<ProdutoModel>> listar() async {
    final response = await service.listar();
    return response;
  }

  Future<List<Categoria>> listarCategorias() => service.listarCategorias();
  
  Future<List<Subcategoria>> listarSubcategorias(int categoriaId) => 
      service.listarSubcategoriasPorCategoria(categoriaId);

  Future<ProdutoModel> visualizar(int id) => service.visualizar(id);
  Future<ProdutoModel> criar(ProdutoModel produto) => service.criar(produto);
  Future<ProdutoModel> atualizar(int id, ProdutoModel produto) => service.atualizar(id, produto);
  Future<void> deletar(int id) => service.deletar(id);
  Future<ProdutoModel> toggleDisponibilidade(int id, bool disponivel) => service.toggleDisponibilidade(id, disponivel);
  Future<ProdutoModel> atualizarEstoque(int id, int? quantidade) => service.atualizarEstoque(id, quantidade);
}
