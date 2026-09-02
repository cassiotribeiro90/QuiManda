import 'package:flutter/material.dart';
import '../../../shared/utils/image_helper.dart';

class AllPedido {
  final int id;
  final String codigo;
  final int usuarioId;
  final int lojaId;
  final int? enderecoId;
  final String status;
  final Map<String, dynamic>? statusHistorico;
  final DateTime dataPedido;
  final DateTime? dataConfirmacao;
  final DateTime? dataPreparo;
  final DateTime? dataSaida;
  final DateTime? dataEntrega;
  final DateTime? dataCancelamento;
  final double subtotal;
  final double taxaEntrega;
  final double desconto;
  final double total;
  final String? formaPagamento;
  final String? pagamentoStatus;
  final double? trocoPara;
  final Map<String, dynamic>? pagamentoDetalhes;
  final Map<String, dynamic>? pagamentoConfig;
  final Map<String, dynamic>? enderecoEntrega;
  final int? tempoEsperaMin;
  final double? distanciaKm;
  final String? observacoes;
  final int? tempoRealMin;
  final double? entregadorLat;
  final double? entregadorLng;
  final DateTime? entregadorAtualizadoEm;
  final String? canceladoPor;
  final String? canceladoMotivo;
  final DateTime criadoEm;
  final DateTime? atualizadoEm;
  final DateTime? deletadoEm;

  // Campos adicionais (relacionamentos)
  final String? clienteNome;
  final String? clienteTelefone;
  final String? lojaNome;
  final String? lojaImagem;
  final List<AllPedidoItem>? itens;

  AllPedido({
    required this.id,
    required this.codigo,
    required this.usuarioId,
    required this.lojaId,
    this.enderecoId,
    required this.status,
    this.statusHistorico,
    required this.dataPedido,
    this.dataConfirmacao,
    this.dataPreparo,
    this.dataSaida,
    this.dataEntrega,
    this.dataCancelamento,
    required this.subtotal,
    required this.taxaEntrega,
    required this.desconto,
    required this.total,
    this.formaPagamento,
    this.pagamentoStatus,
    this.trocoPara,
    this.pagamentoDetalhes,
    this.pagamentoConfig,
    this.enderecoEntrega,
    this.tempoEsperaMin,
    this.distanciaKm,
    this.observacoes,
    this.tempoRealMin,
    this.entregadorLat,
    this.entregadorLng,
    this.entregadorAtualizadoEm,
    this.canceladoPor,
    this.canceladoMotivo,
    required this.criadoEm,
    this.atualizadoEm,
    this.deletadoEm,
    this.clienteNome,
    this.clienteTelefone,
    this.lojaNome,
    this.lojaImagem,
    this.itens,
  });

  // ⭐ GETTERS ÚTEIS
  String get statusLabel => getStatusLabel(status);
  Color get statusColor => getStatusColor(status);
  IconData get statusIcon => getStatusIcon(status);
  bool get isAtivo => !['entregue', 'cancelado', 'recusado'].contains(status);
  bool get isNovo => status == 'novo';
  bool get isEntregue => status == 'entregue';
  bool get isCancelado => ['cancelado', 'recusado'].contains(status);
  String get dataFormatada => _formatDate(criadoEm);
  String get horarioFormatado => _formatTime(criadoEm);
  String get totalFormatado => 'R\$ ${total.toStringAsFixed(2)}';
  String get subtotalFormatado => 'R\$ ${subtotal.toStringAsFixed(2)}';
  String get taxaEntregaFormatada => 'R\$ ${taxaEntrega.toStringAsFixed(2)}';
  String get descontoFormatada => 'R\$ ${desconto.toStringAsFixed(2)}';
  String get trocoParaFormatado => trocoPara != null ? 'R\$ ${trocoPara!.toStringAsFixed(2)}' : '--';
  String get distanciaFormatada => distanciaKm != null ? '${distanciaKm!.toStringAsFixed(1)} km' : '--';
  
  String get lojaImagemUrl {
    if (lojaImagem == null || lojaImagem!.isEmpty) return '';
    return ImageHelper.getFullImageUrl(lojaImagem);
  }

  String get enderecoCompleto {
    if (enderecoEntrega == null) return 'Endereço não informado';
    final e = enderecoEntrega!;
    final parts = [
      e['logradouro'],
      e['numero'],
      e['complemento'],
      e['bairro'],
      e['cidade'],
      e['uf'],
    ].where((p) => p != null && p.toString().isNotEmpty);
    return parts.join(', ');
  }

  String get formaPagamentoLabel {
    const labels = {
      'credito': 'Crédito',
      'debito': 'Débito',
      'dinheiro': 'Dinheiro',
      'pix': 'PIX',
      'vr': 'Vale Refeição',
      'cartao_entrega': 'Cartão na Entrega',
      'cartao_credito': 'Cartão Crédito',
      'cartao_debito': 'Cartão Débito',
      'vale_refeicao': 'Vale Refeição',
      'vale_alimentacao': 'Vale Alimentação',
      'transferencia': 'Transferência',
      'boleto': 'Boleto',
      'outro': 'Outro',
    };
    return labels[formaPagamento] ?? formaPagamento ?? '--';
  }

  String get pagamentoStatusLabel {
    const labels = {
      'pendente': 'Pendente',
      'aprovado': 'Aprovado',
      'recusado': 'Recusado',
      'cancelado': 'Cancelado',
      'estornado': 'Estornado',
      'em_analise': 'Em Análise',
    };
    return labels[pagamentoStatus] ?? pagamentoStatus ?? '--';
  }

  Color get pagamentoStatusColor {
    switch (pagamentoStatus) {
      case 'aprovado':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'recusado':
      case 'cancelado':
        return Colors.red;
      case 'estornado':
        return Colors.purple;
      case 'em_analise':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String get canceladoPorLabel {
    const labels = {
      'cliente': 'Cliente',
      'loja': 'Lojista',
      'sistema': 'Sistema',
    };
    return labels[canceladoPor] ?? canceladoPor ?? '--';
  }

  // ⭐ MÉTODOS ESTÁTICOS
  static String getStatusLabel(String status) {
    const labels = {
      'novo': 'Novo',
      'aguardando': 'Aguardando',
      'confirmado': 'Confirmado',
      'preparando': 'Preparando',
      'pronto': 'Pronto',
      'saiu': 'Saiu para entrega',
      'entregue': 'Entregue',
      'cancelado': 'Cancelado',
      'recusado': 'Recusado',
    };
    return labels[status] ?? status;
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'novo':
        return Colors.blue;
      case 'aguardando':
        return Colors.orange;
      case 'confirmado':
        return Colors.green;
      case 'preparando':
        return Colors.orange.shade700;
      case 'pronto':
        return Colors.purple;
      case 'saiu':
        return Colors.indigo;
      case 'entregue':
        return Colors.teal;
      case 'cancelado':
        return Colors.red;
      case 'recusado':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'novo':
        return Icons.fiber_new;
      case 'aguardando':
        return Icons.hourglass_empty;
      case 'confirmado':
        return Icons.check_circle_outline;
      case 'preparando':
        return Icons.kitchen;
      case 'pronto':
        return Icons.done_all;
      case 'saiu':
        return Icons.delivery_dining;
      case 'entregue':
        return Icons.home;
      case 'cancelado':
        return Icons.cancel;
      case 'recusado':
        return Icons.block;
      default:
        return Icons.receipt_long;
    }
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) {
      return 'Hoje, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d atrás';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ⭐ FACTORY FROM JSON
  factory AllPedido.fromJson(Map<String, dynamic> json) {
    return AllPedido(
      id: json['id'] ?? 0,
      codigo: json['codigo'] ?? '',
      usuarioId: json['usuario_id'] ?? 0,
      lojaId: json['loja_id'] ?? 0,
      enderecoId: json['endereco_id'],
      status: json['status'] ?? 'novo',
      statusHistorico: json['status_historico'],
      dataPedido: _parseDate(json['data_pedido'] ?? json['criado_em']),
      dataConfirmacao: _parseDate(json['data_confirmacao']),
      dataPreparo: _parseDate(json['data_preparo']),
      dataSaida: _parseDate(json['data_saida']),
      dataEntrega: _parseDate(json['data_entrega']),
      dataCancelamento: _parseDate(json['data_cancelamento']),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      taxaEntrega: (json['taxa_entrega'] ?? 0).toDouble(),
      desconto: (json['desconto'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      formaPagamento: json['forma_pagamento'],
      pagamentoStatus: json['pagamento_status'],
      trocoPara: json['troco_para']?.toDouble(),
      pagamentoDetalhes: json['pagamento_detalhes'],
      pagamentoConfig: json['pagamento_config'],
      enderecoEntrega: json['endereco_entrega'],
      tempoEsperaMin: json['tempo_espera_min'],
      distanciaKm: json['distancia_km']?.toDouble(),
      observacoes: json['observacoes'],
      tempoRealMin: json['tempo_real_min'],
      entregadorLat: json['entregador_lat']?.toDouble(),
      entregadorLng: json['entregador_lng']?.toDouble(),
      entregadorAtualizadoEm: _parseDate(json['entregador_atualizado_em']),
      canceladoPor: json['cancelado_por'],
      canceladoMotivo: json['cancelado_motivo'],
      criadoEm: _parseDate(json['criado_em']),
      atualizadoEm: _parseDate(json['atualizado_em']),
      deletadoEm: _parseDate(json['deletado_em']),
      clienteNome: json['cliente_nome'],
      clienteTelefone: json['cliente_telefone'],
      lojaNome: json['loja_nome'],
      lojaImagem: json['loja_imagem'],
      itens: json['itens'] != null
          ? (json['itens'] as List)
              .map((i) => AllPedidoItem.fromJson(i))
              .toList()
          : null,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}

class AllPedidoItem {
  final int? id;
  final int? produtoId;
  final String nome;
  final int quantidade;
  final double precoUnitario;
  final double total;
  final String? observacoes;
  final String? imagem;

  AllPedidoItem({
    this.id,
    this.produtoId,
    required this.nome,
    required this.quantidade,
    required this.precoUnitario,
    required this.total,
    this.observacoes,
    this.imagem,
  });

  String get totalFormatado => 'R\$ ${total.toStringAsFixed(2)}';
  String get precoUnitarioFormatado => 'R\$ ${precoUnitario.toStringAsFixed(2)}';

  String get imagemUrl {
    if (imagem == null || imagem!.isEmpty) return '';
    return ImageHelper.getFullImageUrl(imagem);
  }

  factory AllPedidoItem.fromJson(Map<String, dynamic> json) {
    return AllPedidoItem(
      id: json['id'],
      produtoId: json['produto_id'],
      nome: json['nome'] ?? '',
      quantidade: json['quantidade'] ?? 0,
      precoUnitario: (json['preco_unitario'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      observacoes: json['observacoes'],
      imagem: json['imagem'],
    );
  }
}
