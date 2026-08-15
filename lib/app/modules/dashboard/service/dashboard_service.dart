import '../repository/dashboard_repository.dart';

class DashboardService {
  final DashboardRepository _repository;
  DashboardService(this._repository);

  Future<Map<String, dynamic>> getStats() => _repository.getStats();
}
