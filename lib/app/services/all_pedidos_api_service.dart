import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../modules/all_pedidos/bloc/all_pedidos_state.dart';
import '../modules/all_pedidos/models/all_pedido_model.dart';

class AllPedidosApiService {
  final ApiClient _apiClient;

  AllPedidosApiService(this._apiClient);

  Future<Map<String, dynamic>> fetchPedidos(AllPedidosFilter filter) async {
    final params = filter.toQueryParams();
    
    // 🔥 Log da URL completa para depuração (Igual ao ChatRepository)
    final baseUrl = _apiClient.dio.options.baseUrl;
    final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    debugPrint('🔗 [AllPedidosApiService] URL final: $baseUrl/api/lojista/all-pedidos?$queryString');

    final response = await _apiClient.get(
      '/api/lojista/all-pedidos', 
      queryParams: params,
    );

    return response.data['data'] ?? {};
  }

  Future<AllPedido> fetchPedidoDetail(int id) async {
    final response = await _apiClient.get('/api/lojista/lojista-pedido/view', queryParams: {'id': id});
    return AllPedido.fromJson(response.data['data'] ?? response.data);
  }

  Future<bool> updateStatus(int id, String status) async {
    try {
      await _apiClient.post(
        '/api/lojista/lojista-pedido/atualizar-status',
        queryParams: {'id': id},
        data: {'status': status},
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
