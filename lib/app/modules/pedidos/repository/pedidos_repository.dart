import '../../../core/api_client.dart';

class PedidosRepository {
  final ApiClient _apiClient;
  PedidosRepository(this._apiClient);

  Future<List<Map<String, dynamic>>> getPedidos() async {
    // Mock
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'id': '101', 'cliente': 'João Silva', 'valor': 45.0, 'status': 'Pendente', 'data': '2026-08-14T10:00:00Z'},
      {'id': '102', 'cliente': 'Maria Oliveira', 'valor': 82.50, 'status': 'Preparando', 'data': '2026-08-14T11:30:00Z'},
      {'id': '103', 'cliente': 'Carlos Souza', 'valor': 120.0, 'status': 'Entregue', 'data': '2026-08-14T12:15:00Z'},
    ];
  }
}
