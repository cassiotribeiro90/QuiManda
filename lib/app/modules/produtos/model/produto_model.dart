class ProdutoModel {
  final String id;
  final String nome;
  final String descricao;
  final double preco;
  final String? imagemUrl;
  final bool disponivel;

  ProdutoModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    this.imagemUrl,
    this.disponivel = true,
  });

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      preco: (json['preco'] as num).toDouble(),
      imagemUrl: json['imagemUrl'],
      disponivel: json['disponivel'] ?? true,
    );
  }
}
