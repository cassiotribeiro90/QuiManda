import '../../../core/api_client.dart';

class DashboardRepository {
  DashboardRepository();

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
