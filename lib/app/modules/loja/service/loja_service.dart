import '../model/loja_model.dart';
import '../repository/loja_repository.dart';

class LojaService {
  final LojaRepository _repository;
  LojaService(this._repository);

  Future<LojaModel> getLoja() async {
    final data = await _repository.getLoja();
    return LojaModel.fromJson(data);
  }

  Future<void> updateLoja(LojaModel loja) async {
    await _repository.updateLoja({
      'nome': loja.nome,
      'endereco': loja.endereco,
      'telefone': loja.telefone,
      'aberta': loja.aberta,
    });
  }
}
