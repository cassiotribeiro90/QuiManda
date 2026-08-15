import '../model/pedido_model.dart';
import '../repository/pedidos_repository.dart';

class PedidosService {
  final PedidosRepository _repository;
  PedidosService(this._repository);

  Future<List<PedidoModel>> getPedidos() async {
    final data = await _repository.getPedidos();
    return data.map((json) => PedidoModel.fromJson(json)).toList();
  }
}
