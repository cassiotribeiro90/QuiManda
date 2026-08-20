import '../../../core/api_client.dart';
import '../../../core/app_config.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await _apiClient.get(AppConfig.dashboard);

    if (response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }

    throw Exception(response.data['message'] ?? 'Erro ao carregar dashboard');
  }
}