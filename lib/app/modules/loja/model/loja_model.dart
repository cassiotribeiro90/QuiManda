class LojaModel {
  final String id;
  final String nome;
  final String endereco;
  final String telefone;
  final bool aberta;

  LojaModel({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.telefone,
    required this.aberta,
  });

  factory LojaModel.fromJson(Map<String, dynamic> json) {
    return LojaModel(
      id: json['id'],
      nome: json['nome'],
      endereco: json['endereco'],
      telefone: json['telefone'],
      aberta: json['aberta'] ?? true,
    );
  }
}
