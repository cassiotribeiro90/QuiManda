import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_state.dart';
import '../service/dashboard_service.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardService _service;

  DashboardCubit(this._service) : super(DashboardInitial());

  Future<void> loadDashboard() async {
    emit(DashboardLoading());
    try {
      final stats = await _service.getStats();
      emit(DashboardLoaded(
        totalPedidos: stats['totalPedidos'],
        faturamento: stats['faturamento'],
        produtosAtivos: stats['produtosAtivos'],
      ));
    } catch (e) {
      emit(DashboardError('Falha ao carregar dashboard: ${e.toString()}'));
    }
  }
}
