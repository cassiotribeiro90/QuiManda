import 'package:equatable/equatable.dart';

class LojistaModel extends Equatable {
  final int id;
  final String nome;
  final String? email;
  final String? telefone;
  final String? cpfCnpj;
  final int status; // 1=ativo, 0=inativo
  final String? ultimoLoginEm;
  final String? criadoEm;

  const LojistaModel({
    required this.id,
    required this.nome,
    this.email,
    this.telefone,
    this.cpfCnpj,
    this.status = 1,
    this.ultimoLoginEm,
    this.criadoEm,
  });

  factory LojistaModel.fromJson(Map<String, dynamic> json) {
    return LojistaModel(
      id: json['id'] as int? ?? 0,
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString(),
      telefone: json['telefone']?.toString(),
      cpfCnpj: json['cpf_cnpj']?.toString(),
      status: json['status'] as int? ?? 1,
      ultimoLoginEm: json['ultimo_login_em']?.toString(),
      criadoEm: json['criado_em']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'email': email,
    'telefone': telefone,
    'cpf_cnpj': cpfCnpj,
    'status': status,
  };

  bool get isAtivo => status == 1;

  @override
  List<Object?> get props => [id, nome, email, status];
}
