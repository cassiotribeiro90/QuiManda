// lib/app/modules/pedidos/repository/pedidos_repository.dart
import '../model/pedido_model.dart';
import '../service/pedidos_service.dart';

class PedidosRepository {
  final PedidosService _service;
  
  // 🔥 Cache simples para evitar recarregar desnecessário
  Map<String, dynamic>? _cache;
  DateTime? _cacheTime;
  final Duration _cacheDuration = const Duration(seconds: 15);

  PedidosRepository(this._service);

  Future<List<PedidoModel>> listarAtivos() async {
    final data = await _service.listarAtivos();
    final items = data['data']?['items'] as List? ?? [];
    return items.map((e) => PedidoModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> listarAtivosAgrupados({bool forceRefresh = false}) async {
    // 🔥 Se o cache é válido e não forçado, retorna cache
    if (!forceRefresh && _cache != null && _cacheTime != null) {
      final age = DateTime.now().difference(_cacheTime!);
      if (age < _cacheDuration) {
        return _cache!;
      }
    }

    final data = await _service.listarAtivos();
    _cache = data['data'] as Map<String, dynamic>? ?? {};
    _cacheTime = DateTime.now();
    return _cache!;
  }

  Future<(List<PedidoModel>, int)> listar({
    String? status,
    int? lojaId,
    String? dataInicio,
    String? dataFim,
    int page = 1,
    int perPage = 20,
  }) async {
    final data = await _service.listar(
      status: status,
      lojaId: lojaId,
      dataInicio: dataInicio,
      dataFim: dataFim,
      page: page,
      perPage: perPage,
    );
    final items = (data['data']?['items'] as List?)?.map((e) => PedidoModel.fromJson(e)).toList() ?? [];
    final total = (data['data']?['pagination']?['total'] as num?)?.toInt() ?? 0;
    return (items, total);
  }

  Future<PedidoModel> visualizar(int id) async {
    final data = await _service.visualizar(id);
    return PedidoModel.fromJson(data['data']);
  }

  Future<PedidoModel> aceitar(int id) async {
    final data = await _service.aceitar(id);
    return PedidoModel.fromJson(data['data']);
  }

  Future<PedidoModel> recusar(int id, {String? motivo, String? motivoCodigo}) async {
    final data = await _service.recusar(id, motivo: motivo, motivoCodigo: motivoCodigo);
    return PedidoModel.fromJson(data['data']);
  }

  Future<PedidoModel> atualizarStatus(int id, String status, {String? motivo}) async {
    final data = await _service.atualizarStatus(id, status, motivo: motivo);
    return PedidoModel.fromJson(data['data']);
  }

  Future<PedidoModel> cancelar(int id, String motivo) async {
    final data = await _service.cancelar(id, motivo);
    return PedidoModel.fromJson(data['data']);
  }

  Future<Map<String, int>> statusCount() async {
    final data = await _service.statusCount();
    final counts = data['data']?['counts'] as Map<String, dynamic>? ?? {};
    return counts.map((key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0));
  }

  Future<List<dynamic>> historico(int id) async {
    final data = await _service.historico(id);
    return data['data'] as List? ?? [];
  }
}
