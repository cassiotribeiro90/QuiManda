import '../../../shared/utils/image_helper.dart';

class LojaModel {
  final int id;
  final String nome;
  final String? descricao;
  final String? corTema;
  final String? whatsapp;
  final String? email;
  final String? instagram;
  final String? logo;
  final String? capa;

  String get logoUrl => logo != null && logo!.isNotEmpty
      ? ImageHelper.getFullImageUrl(logo)
      : '';

  String get capaUrl => capa != null && capa!.isNotEmpty
      ? ImageHelper.getFullImageUrl(capa)
      : '';

  LojaModel({
    required this.id,
    required this.nome,
    this.descricao,
    this.corTema,
    this.whatsapp,
    this.email,
    this.instagram,
    this.logo,
    this.capa,
  });

  factory LojaModel.fromJson(Map<String, dynamic> json) => LojaModel(
    id: json['id'] as int? ?? 0,
    nome: json['nome']?.toString() ?? '',
    descricao: json['descricao']?.toString(),
    corTema: json['cor_tema']?.toString(),
    whatsapp: json['whatsapp']?.toString(),
    email: json['email']?.toString(),
    instagram: json['instagram']?.toString(),
    logo: json['logo']?.toString(),
    capa: json['capa']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'descricao': descricao,
    'cor_tema': corTema,
    'whatsapp': whatsapp,
    'email': email,
    'instagram': instagram,
  };

  LojaModel copyWith({
    int? id,
    String? nome,
    String? descricao,
    String? corTema,
    String? whatsapp,
    String? email,
    String? instagram,
    String? logo,
    String? capa,
  }) {
    return LojaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      corTema: corTema ?? this.corTema,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      instagram: instagram ?? this.instagram,
      logo: logo ?? this.logo,
      capa: capa ?? this.capa,
    );
  }
}
