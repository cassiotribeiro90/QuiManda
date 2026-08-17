// lib/app/modules/pedidos/service/pedidos_service.dart
import '../../../core/api_client.dart';

class PedidosService {
  final ApiClient _apiClient;
  
  // 🔥 Rate limiting simples
  DateTime? _lastAtivosRequest;
  final Duration _minInterval = const Duration(seconds: 5);
  Map<String, dynamic>? _lastAtivosResponse;

  PedidosService(this._apiClient);

  // 🔥 Listar pedidos ativos
  Future<Map<String, dynamic>> listarAtivos() async {
    // 🔥 Evita requisições muito frequentes (retorna cache do service se for muito rápido)
    if (_lastAtivosRequest != null && _lastAtivosResponse != null) {
      final elapsed = DateTime.now().difference(_lastAtivosRequest!);
      if (elapsed < _minInterval) {
        return _lastAtivosResponse!;
      }
    }
    
    _lastAtivosRequest = DateTime.now();
    final response = await _apiClient.get(
      '/api/lojista/lojista-pedido/ativos'
    );
    _lastAtivosResponse = response.data;
    return response.data;
  }

  // 🔥 Listar pedidos (com paginação e filtros)
  Future<Map<String, dynamic>> listar({
    String? status,
    int? lojaId,
    String? dataInicio,
    String? dataFim,
    int page = 1,
    int perPage = 20,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (lojaId != null) query['loja_id'] = lojaId;
    if (dataInicio != null && dataInicio.isNotEmpty) query['data_inicio'] = dataInicio;
    if (dataFim != null && dataFim.isNotEmpty) query['data_fim'] = dataFim;

    final response = await _apiClient.get(
      '/api/lojista/lojista-pedido',
      queryParams: query,
    );
    return response.data;
  }

  // 🔥 Visualizar pedido (query string)
  Future<Map<String, dynamic>> visualizar(int id) async {
    final response = await _apiClient.get(
      '/api/lojista/lojista-pedido/view',
      queryParams: {'id': id},
    );
    return response.data;
  }

  // 🔥 Aceitar pedido (query string)
  Future<Map<String, dynamic>> aceitar(int id) async {
    final response = await _apiClient.post(
      '/api/lojista/lojista-pedido/aceitar',
      queryParams: {'id': id},
    );
    return response.data;
  }

  // 🔥 Recusar pedido (query string)
  Future<Map<String, dynamic>> recusar(int id, {String? motivo, String? motivoCodigo}) async {
    final data = <String, dynamic>{};
    if (motivo != null) data['motivo'] = motivo;
    if (motivoCodigo != null) data['motivo_codigo'] = motivoCodigo;
    
    final response = await _apiClient.post(
      '/api/lojista/lojista-pedido/recusar',
      queryParams: {'id': id},
      data: data,
    );
    return response.data;
  }

  // 🔥 Atualizar status (query string)
  Future<Map<String, dynamic>> atualizarStatus(int id, String status, {String? motivo}) async {
    final data = <String, dynamic>{'status': status};
    if (motivo != null) data['motivo'] = motivo;
    
    final response = await _apiClient.post(
      '/api/lojista/lojista-pedido/atualizar-status',
      queryParams: {'id': id},
      data: data,
    );
    return response.data;
  }

  // 🔥 Cancelar pedido (query string)
  Future<Map<String, dynamic>> cancelar(int id, String motivo) async {
    final response = await _apiClient.post(
      '/api/lojista/lojista-pedido/cancelar',
      queryParams: {'id': id},
      data: {'motivo': motivo},
    );
    return response.data;
  }

  // 🔥 Contagem de status
  Future<Map<String, dynamic>> statusCount() async {
    final response = await _apiClient.get(
      '/api/lojista/lojista-pedido/status-count'
    );
    return response.data;
  }

  // 🔥 Histórico do pedido (query string)
  Future<Map<String, dynamic>> historico(int id) async {
    final response = await _apiClient.get(
      '/api/lojista/lojista-pedido/historico',
      queryParams: {'id': id},
    );
    return response.data;
  }
}
