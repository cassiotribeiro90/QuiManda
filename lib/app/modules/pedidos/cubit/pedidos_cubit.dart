import 'package:flutter_bloc/flutter_bloc.dart';
import 'pedidos_state.dart';
import '../service/pedidos_service.dart';

class PedidosCubit extends Cubit<PedidosState> {
  final PedidosService _service;

  PedidosCubit(this._service) : super(PedidosInitial());

  Future<void> loadPedidos() async {
    emit(PedidosLoading());
    try {
      final pedidos = await _service.getPedidos();
      emit(PedidosLoaded(pedidos));
    } catch (e) {
      emit(PedidosError('Falha ao carregar pedidos: ${e.toString()}'));
    }
  }
}
