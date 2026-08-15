import '../../../core/api_client.dart';

class DashboardRepository {
  final ApiClient _apiClient;
  DashboardRepository(this._apiClient);

  Future<Map<String, dynamic>> getStats() async {
    // Mocking response
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'totalPedidos': 15,
      'faturamento': 1250.50,
      'produtosAtivos': 42
    };
  }
}
