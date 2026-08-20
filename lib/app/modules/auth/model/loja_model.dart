import 'package:equatable/equatable.dart';

class LojaModel extends Equatable {
  final int id;
  final String nome;
  final String? logradouro;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final String? cep;
  final String? telefone;

  const LojaModel({
    required this.id,
    required this.nome,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.estado,
    this.cep,
    this.telefone,
  });

  factory LojaModel.fromJson(Map<String, dynamic> json) => LojaModel(
        id: json['id'] as int,
        nome: json['nome'] as String,
        logradouro: json['logradouro'] as String?,
        numero: json['numero']?.toString(),
        complemento: json['complemento'] as String?,
        bairro: json['bairro'] as String?,
        cidade: json['cidade'] as String?,
        estado: json['estado'] as String?,
        cep: json['cep'] as String?,
        telefone: json['telefone'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'logradouro': logradouro,
        'numero': numero,
        'complemento': complemento,
        'bairro': bairro,
        'cidade': cidade,
        'estado': estado,
        'cep': cep,
        'telefone': telefone,
      };

  String get enderecoCompleto {
    final parts = [logradouro, numero, complemento, bairro, cidade, estado]
        .where((e) => e != null && e.toString().isNotEmpty)
        .cast<String>();
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [id, nome, logradouro, numero];
}
