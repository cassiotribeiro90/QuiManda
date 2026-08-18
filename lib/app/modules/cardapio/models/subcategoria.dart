class Subcategoria {
  final int id;
  final int categoriaId;
  final String nome;

  Subcategoria({
    required this.id,
    required this.categoriaId,
    required this.nome,
  });

  factory Subcategoria.fromJson(Map<String, dynamic> json) {
    return Subcategoria(
      id: json['id'] as int,
      categoriaId: json['categoria_id'] as int,
      nome: json['nome'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoria_id': categoriaId,
    'nome': nome,
  };
}
