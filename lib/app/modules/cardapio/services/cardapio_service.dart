import 'package:get_it/get_it.dart';
import '../../../core/api_client.dart';
import '../models/produto_model.dart';
import '../models/categoria.dart';
import '../models/subcategoria.dart';

class CardapioService {
  final ApiClient _apiClient = GetIt.I<ApiClient>();

  Future<List<ProdutoModel>> listar() async {
    final response = await _apiClient.get('/api/lojista/cardapio');
    final data = response.data['data'] as List;
    return data.map((json) => ProdutoModel.fromJson(json)).toList();
  }

  Future<List<Categoria>> listarCategorias() async {
    final response = await _apiClient.dio.get('/api/lojista/categorias');
    final data = response.data['data'] as List;
    return data.map((json) => Categoria.fromJson(json)).toList();
  }

  Future<List<Subcategoria>> listarSubcategoriasPorCategoria(int categoriaId) async {
    final response = await _apiClient.dio.get(
      '/api/lojista/subcategoria/por-categoria',
      queryParameters: {'id': categoriaId},
    );
    final data = response.data['data'] as List;
    return data.map((json) => Subcategoria.fromJson(json)).toList();
  }

  Future<ProdutoModel> visualizar(int id) async {
    final response = await _apiClient.get('/api/lojista/cardapio/$id');
    return ProdutoModel.fromJson(response.data['data']);
  }

  Future<ProdutoModel> criar(ProdutoModel produto) async {
    final response = await _apiClient.post(
      '/api/lojista/cardapio/create',
      data: produto.toJson(),
    );
    return ProdutoModel.fromJson(response.data['data']);
  }

  Future<ProdutoModel> atualizar(int id, ProdutoModel produto) async {
    final response = await _apiClient.put(
      '/api/lojista/cardapio/update/$id',
      data: produto.toJson(),
    );
    return ProdutoModel.fromJson(response.data['data']);
  }

  Future<void> deletar(int id) async {
    await _apiClient.delete('/api/lojista/cardapio/delete/$id');
  }

  Future<ProdutoModel> toggleDisponibilidade(int id, bool disponivel) async {
    final response = await _apiClient.dio.post(
      '/api/lojista/cardapio/toggle/$id',
      data: {'disponivel': disponivel ? 1 : 0},
    );
    return ProdutoModel.fromJson(response.data['data']);
  }

  Future<ProdutoModel> atualizarEstoque(int id, int? quantidade) async {
    final response = await _apiClient.dio.post(
      '/api/lojista/cardapio/estoque/$id',
      data: {'estoque': quantidade}, // null = ilimitado
    );
    return ProdutoModel.fromJson(response.data['data']);
  }
}
