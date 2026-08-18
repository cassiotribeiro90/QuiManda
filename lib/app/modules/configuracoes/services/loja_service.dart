
import '../../../core/api_client.dart';
import '../models/loja_model.dart';

class LojaService {
  final ApiClient _api;

  LojaService(this._api);

  Future<LojaModel> getLoja() async {
    try {
      final response = await _api.dio.get('/api/lojista/loja');
      final data = response.data['data'];
      return LojaModel.fromJson(data);
    } catch (e) {
      throw Exception('Erro ao carregar dados da loja: $e');
    }
  }

  Future<LojaModel> updateLoja(LojaModel loja) async {
    try {
      final response = await _api.dio.put(
        '/api/lojista/loja', 
        data: loja.toJson()
      );
      final data = response.data['data'];
      return LojaModel.fromJson(data);
    } catch (e) {
      throw Exception('Erro ao atualizar configurações da loja: $e');
    }
  }
}
