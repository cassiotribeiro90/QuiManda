import '../../../core/api_client.dart';

class ProdutosRepository {
  final ApiClient _apiClient;
  ProdutosRepository(this._apiClient);

  Future<List<Map<String, dynamic>>> getProdutos() async {
    // Mock
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'id': '1', 'nome': 'Hambúrguer Clássico', 'descricao': 'Pão, carne e queijo', 'preco': 25.0, 'disponivel': true},
      {'id': '2', 'nome': 'Batata Frita', 'descricao': 'Porção individual', 'preco': 15.0, 'disponivel': true},
      {'id': '3', 'nome': 'Refrigerante Lata', 'descricao': '350ml', 'preco': 6.0, 'disponivel': true},
    ];
  }

  Future<void> saveProduto(Map<String, dynamic> data) async {
    // Mock
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
