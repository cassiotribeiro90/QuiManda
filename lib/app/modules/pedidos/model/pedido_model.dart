// lib/app/modules/pedidos/model/pedido_model.dart
import 'package:equatable/equatable.dart';

class PedidoModel extends Equatable {
  final int id;
  final String? codigo;
  final String? clienteNome;
  final int lojaId;
  final String status;
  final double total;
  final String? criadoEm;
  final int tempoEspera;
  final int naoLidas;
  final List<PedidoItemModel>? itens;
  final String? clienteTelefone;
  final double? subtotal;
  final double? taxaEntrega;
  final double? desconto;
  final String? formaPagamento;
  final String? pagamentoStatus;
  final double? trocoPara;
  final dynamic enderecoEntrega;
  final String? observacoes;
  final double? distanciaKm;
  final int? tempoEsperaMin;
  final String? dataConfirmacao;
  final String? dataPreparo;
  final String? dataSaida;
  final String? dataEntrega;
  final dynamic entregador;

  const PedidoModel({
    required this.id,
    this.codigo,
    this.clienteNome,
    required this.lojaId,
    required this.status,
    required this.total,
    this.criadoEm,
    this.tempoEspera = 0,
    this.naoLidas = 0,
    this.itens,
    this.clienteTelefone,
    this.subtotal,
    this.taxaEntrega,
    this.desconto,
    this.formaPagamento,
    this.pagamentoStatus,
    this.trocoPara,
    this.enderecoEntrega,
    this.observacoes,
    this.distanciaKm,
    this.tempoEsperaMin,
    this.dataConfirmacao,
    this.dataPreparo,
    this.dataSaida,
    this.dataEntrega,
    this.entregador,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      id: json['id'] as int? ?? 0,
      codigo: json['codigo']?.toString(),
      clienteNome: json['cliente_nome']?.toString(),
      lojaId: json['loja_id'] as int? ?? 0,
      status: json['status']?.toString() ?? 'novo',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      criadoEm: json['criado_em']?.toString(),
      tempoEspera: json['tempo_espera'] as int? ?? 0,
      naoLidas: json['nao_lidas'] as int? ?? 0,
      itens: (json['itens'] as List?)?.map((e) => PedidoItemModel.fromJson(e)).toList(),
      clienteTelefone: json['cliente_telefone']?.toString(),
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      taxaEntrega: (json['taxa_entrega'] as num?)?.toDouble(),
      desconto: (json['desconto'] as num?)?.toDouble(),
      formaPagamento: json['forma_pagamento']?.toString(),
      pagamentoStatus: json['pagamento_status']?.toString(),
      trocoPara: (json['troco_para'] as num?)?.toDouble(),
      enderecoEntrega: json['endereco_entrega'],
      observacoes: json['observacoes']?.toString(),
      distanciaKm: (json['distancia_km'] as num?)?.toDouble(),
      tempoEsperaMin: json['tempo_espera_min'] as int?,
      dataConfirmacao: json['data_confirmacao']?.toString(),
      dataPreparo: json['data_preparo']?.toString(),
      dataSaida: json['data_saida']?.toString(),
      dataEntrega: json['data_entrega']?.toString(),
      entregador: json['entregador'],
    );
  }

  bool get isAtivo => ['novo', 'em_preparo', 'pronto', 'saiu', 'aguardando', 'confirmado'].contains(status);
  bool get isNovo => status == 'novo';
  bool get isEmPreparo => status == 'em_preparo';
  bool get isPronto => status == 'pronto';
  bool get isSaiu => status == 'saiu';
  bool get isEntregue => status == 'entregue';
  bool get isCancelado => status == 'cancelado';
  bool get isRecusado => status == 'recusado';

  String get statusLabel {
    switch (status) {
      case 'novo': return 'Novo';
      case 'em_preparo': return 'Em preparo';
      case 'pronto': return 'Pronto';
      case 'saiu': return 'Saiu para entrega';
      case 'entregue': return 'Entregue';
      case 'cancelado': return 'Cancelado';
      case 'recusado': return 'Recusado';
      default: return status;
    }
  }

  @override
  List<Object?> get props => [id, status, total, tempoEspera, naoLidas];
}

class PedidoItemModel extends Equatable {
  final String nome;
  final int quantidade;
  final double precoUnitario;
  final double? total;

  const PedidoItemModel({
    required this.nome,
    required this.quantidade,
    required this.precoUnitario,
    this.total,
  });

  factory PedidoItemModel.fromJson(Map<String, dynamic> json) {
    return PedidoItemModel(
      nome: json['nome']?.toString() ?? '',
      quantidade: json['quantidade'] as int? ?? 0,
      precoUnitario: (json['preco_unitario'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [nome, quantidade, precoUnitario];
}
