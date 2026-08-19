import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/dashboard_service.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardService _dashboardService;

  DashboardCubit(this._dashboardService) : super(DashboardInitial());

  Future<void> loadDashboard() async {
    emit(DashboardLoading());
    try {
      final data = await _dashboardService.fetchDashboard();

      emit(DashboardLoaded(data));
    } catch (e) {
      emit(DashboardError('Erro de conexão: $e'));
    }
  }
}