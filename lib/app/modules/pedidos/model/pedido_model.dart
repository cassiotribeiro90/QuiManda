// lib/app/modules/pedidos/model/pedido_model.dart
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'pedido_item_model.dart';

class PedidoModel extends Equatable {
  final int id;
  final String? codigo;
  final String? clienteNome;
  final String? clienteTelefone;
  final int lojaId;
  final String status;
  final double total;
  final double? subtotal;
  final double? taxaEntrega;
  final double? desconto;
  final String? formaPagamento;
  final String? pagamentoStatus;
  final double? trocoPara;
  final dynamic enderecoEntrega; // pode ser Map ou String
  final List<PedidoItemModel> itens;
  final String? observacoes;
  final double? distanciaKm;
  final int? tempoEsperaMin;
  final String? criadoEm;
  final String? dataConfirmacao;
  final String? dataPreparo;
  final String? dataSaida;
  final String? dataEntrega;
  final dynamic entregador;
  final int tempoEspera;
  final int naoLidas;
  final double? latitude;
  final double? longitude;

  const PedidoModel({
    required this.id,
    this.codigo,
    this.clienteNome,
    this.clienteTelefone,
    required this.lojaId,
    required this.status,
    required this.total,
    this.subtotal,
    this.taxaEntrega,
    this.desconto,
    this.formaPagamento,
    this.pagamentoStatus,
    this.trocoPara,
    this.enderecoEntrega,
    this.itens = const [],
    this.observacoes,
    this.distanciaKm,
    this.tempoEsperaMin,
    this.criadoEm,
    this.dataConfirmacao,
    this.dataPreparo,
    this.dataSaida,
    this.dataEntrega,
    this.entregador,
    this.tempoEspera = 0,
    this.naoLidas = 0,
    this.latitude,
    this.longitude,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    // Processar itens
    List<PedidoItemModel> itens = [];
    if (json['itens'] != null) {
      if (json['itens'] is List) {
        itens = (json['itens'] as List)
            .map((e) => PedidoItemModel.fromJson(e))
            .toList();
      }
    }

    // Processar endereço
    dynamic endereco = json['endereco_entrega'];
    if (endereco is String && endereco.startsWith('{')) {
      try {
        endereco = jsonDecode(endereco);
      } catch (_) {}
    }

    double? lat;
    double? lng;

    if (endereco is Map<String, dynamic>) {
      lat = (endereco['latitude'] as num?)?.toDouble() ?? (endereco['lat'] as num?)?.toDouble();
      lng = (endereco['longitude'] as num?)?.toDouble() ?? (endereco['lng'] as num?)?.toDouble();
    } else {
      lat = (json['latitude'] as num?)?.toDouble() ?? (json['lat'] as num?)?.toDouble();
      lng = (json['longitude'] as num?)?.toDouble() ?? (json['lng'] as num?)?.toDouble();
    }

    return PedidoModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      codigo: json['codigo']?.toString(),
      clienteNome: json['cliente_nome']?.toString(),
      clienteTelefone: json['cliente_telefone']?.toString(),
      lojaId: json['loja_id'] as int? ?? 0,
      status: json['status']?.toString() ?? 'novo',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      taxaEntrega: (json['taxa_entrega'] as num?)?.toDouble(),
      desconto: (json['desconto'] as num?)?.toDouble(),
      formaPagamento: json['forma_pagamento']?.toString(),
      pagamentoStatus: json['pagamento_status']?.toString(),
      trocoPara: (json['troco_para'] as num?)?.toDouble(),
      enderecoEntrega: endereco,
      itens: itens,
      observacoes: json['observacoes']?.toString(),
      distanciaKm: (json['distancia_km'] as num?)?.toDouble(),
      tempoEsperaMin: json['tempo_espera_min'] as int?,
      criadoEm: json['criado_em']?.toString(),
      dataConfirmacao: json['data_confirmacao']?.toString(),
      dataPreparo: json['data_preparo']?.toString(),
      dataSaida: json['data_saida']?.toString(),
      dataEntrega: json['data_entrega']?.toString(),
      entregador: json['entregador'],
      tempoEspera: json['tempo_espera'] as int? ?? 0,
      naoLidas: json['nao_lidas'] as int? ?? 0,
      latitude: lat,
      longitude: lng,
    );
  }

  bool get isNovo => status == 'novo';
  bool get isEmPreparo => status == 'em_preparo' || status == 'preparando';
  bool get isPronto => status == 'pronto';
  bool get isSaiu => status == 'saiu';
  bool get isPreparando => isEmPreparo;

  String get statusLabel {
    switch (status) {
      case 'novo': return 'Novo';
      case 'em_preparo':
      case 'preparando': return 'Em preparo';
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
