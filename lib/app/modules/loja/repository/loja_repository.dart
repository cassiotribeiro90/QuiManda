import '../../../core/api_client.dart';

class LojaRepository {
  LojaRepository();

  Future<Map<String, dynamic>> getLoja() async {
    // Mock
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'id': '1',
      'nome': 'Hambúrguer do Zé',
      'endereco': 'Rua das Flores, 123',
      'telefone': '(11) 99999-9999',
      'aberta': true,
    };
  }

  Future<void> updateLoja(Map<String, dynamic> data) async {
    // Mock
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
