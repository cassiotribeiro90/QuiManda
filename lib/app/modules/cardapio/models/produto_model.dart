import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../shared/utils/image_helper.dart';

// Função para converter string para double com segurança
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final cleaned = value.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned);
  }
  return null;
}

// Função para converter string para int com segurança
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value == -1 ? null : value;
  if (value is double) return value.toInt() == -1 ? null : value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    return parsed == -1 ? null : parsed;
  }
  return null;
}

// Função para converter string para bool com segurança (0/1 ou true/false)
bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}

class ProdutoModel extends Equatable {
  final int? id;
  final int lojaId;
  final int? subcategoriaId;
  final int? categoriaId; // Adicionado para facilitar a pré-seleção no formulário
  final String? categoriaNome; // Adicionado para agrupamento na lista
  final String tipo;             // 'simples' | 'combo' | 'personalizavel'
  final String nome;
  final String? descricao;
  final String? slug;
  final double preco;
  final double? precoPromocional;
  final String? imagem;
  final List<String>? imagens;
  final List<String>? ingredientes;
  final String? ingredientesTexto;
  final int? calorias;
  final int? pesoGramas;
  final bool contemGluten;
  final bool contemLactose;
  final bool vegano;
  final bool vegetariano;
  final bool apimentado;
  final List<String>? selos;
  final String? disponivelInicio;
  final String? disponivelFim;
  final List<int>? disponivelDias;
  final int? tempoPreparoMin;
  final bool disponivel;
  final int? estoque;
  final int ordem;
  final double notaMedia;
  final int totalAvaliacoes;
  final int visualizacoes;
  final int cliques;
  final bool ativo;
  final bool destaque;
  final String criadoEm;
  final String atualizadoEm;
  final String? deletadoEm;

  const ProdutoModel({
    this.id,
    required this.lojaId,
    this.subcategoriaId,
    this.categoriaId,
    this.categoriaNome,
    this.tipo = 'simples',
    required this.nome,
    this.descricao,
    this.slug,
    required this.preco,
    this.precoPromocional,
    this.imagem,
    this.imagens,
    this.ingredientes,
    this.ingredientesTexto,
    this.calorias,
    this.pesoGramas,
    this.contemGluten = false,
    this.contemLactose = false,
    this.vegano = false,
    this.vegetariano = false,
    this.apimentado = false,
    this.selos,
    this.disponivelInicio,
    this.disponivelFim,
    this.disponivelDias,
    this.tempoPreparoMin,
    this.disponivel = true,
    this.estoque,
    this.ordem = 0,
    this.notaMedia = 0.0,
    this.totalAvaliacoes = 0,
    this.visualizacoes = 0,
    this.cliques = 0,
    this.ativo = true,
    this.destaque = false,
    required this.criadoEm,
    required this.atualizadoEm,
    this.deletadoEm,
  });

  // ===== Status do estoque (calculado) =====
  String get statusEstoque {
    if (estoque == null) return 'ilimitado';
    if (estoque == 0) return 'esgotado';
    if (estoque! <= 5) return 'baixo';
    return 'normal';
  }

  // ===== Preço formatado =====
  String get precoFormatado {
    final valor = precoPromocional ?? preco;
    return 'R\$ ${valor.toStringAsFixed(2)}';
  }

  // 🔥 Getter para URL completa
  String get imagemUrl {
    if (imagem == null || imagem!.isEmpty) return '';
    return ImageHelper.getFullImageUrl(imagem);
  }

  // 🔥 Getter para caminho relativo
  String? get imagemPath => imagem;

  // ===== From JSON =====
  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProdutoModel(
        id: json['id'] as int?,
        lojaId: _parseInt(json['loja_id']) ?? 0,
        subcategoriaId: json['subcategoria_id'] as int?,
        categoriaId: json['categoria_id'] as int?,
        categoriaNome: json['categoria_nome']?.toString(),
        tipo: json['tipo'] as String? ?? 'simples',
        nome: json['nome'] as String? ?? '',
        descricao: json['descricao'] as String?,
        slug: json['slug'] as String?,
        preco: _parseDouble(json['preco']) ?? 0.0,
        precoPromocional: _parseDouble(json['preco_promocional']),
        imagem: json['imagem'] as String?,
        imagens: json['imagens'] is List ? List<String>.from(json['imagens']) : null,
        ingredientes: json['ingredientes'] is List ? List<String>.from(json['ingredientes']) : null,
        ingredientesTexto: json['ingredientes_texto'] as String?,
        calorias: _parseInt(json['calorias']),
        pesoGramas: _parseInt(json['peso_gramas']),
        contemGluten: _parseBool(json['contem_gluten']),
        contemLactose: _parseBool(json['contem_lactose']),
        vegano: _parseBool(json['vegano']),
        vegetariano: _parseBool(json['vegetariano']),
        apimentado: _parseBool(json['apimentado']),
        selos: json['selos'] is List ? List<String>.from(json['selos']) : null,
        disponivelInicio: json['disponivel_inicio'] as String?,
        disponivelFim: json['disponivel_fim'] as String?,
        disponivelDias: json['disponivel_dias'] is List ? List<int>.from(json['disponivel_dias']) : null,
        tempoPreparoMin: _parseInt(json['tempo_preparo_min']),
        disponivel: _parseBool(json['disponivel']),
        estoque: _parseInt(json['estoque']),
        ordem: _parseInt(json['ordem']) ?? 0,
        notaMedia: _parseDouble(json['nota_media']) ?? 0.0,
        totalAvaliacoes: _parseInt(json['total_avaliacoes']) ?? 0,
        visualizacoes: _parseInt(json['visualizacoes']) ?? 0,
        cliques: _parseInt(json['cliques']) ?? 0,
        ativo: _parseBool(json['ativo']),
        destaque: _parseBool(json['destaque']),
        criadoEm: json['criado_em'] as String? ?? DateTime.now().toIso8601String(),
        atualizadoEm: json['atualizado_em'] as String? ?? DateTime.now().toIso8601String(),
        deletadoEm: json['deletado_em'] as String?,
      );
    } catch (e) {
      debugPrint('❌ [MODEL] Erro no fromJson de ProdutoModel: $e');
      debugPrint('📄 [MODEL] JSON problemático: $json');
      rethrow;
    }
  }

  // ===== To JSON =====
  Map<String, dynamic> toJson() => {
    'loja_id': lojaId,
    'subcategoria_id': subcategoriaId,
    'categoria_id': categoriaId,
    'categoria_nome': categoriaNome,
    'tipo': tipo,
    'nome': nome,
    'descricao': descricao,
    'preco': preco,
    'preco_promocional': precoPromocional,
    'imagem': imagem,
    'imagens': imagens,
    'ingredientes': ingredientes,
    'ingredientes_texto': ingredientesTexto,
    'calorias': calorias,
    'peso_gramas': pesoGramas,
    'contem_gluten': contemGluten ? 1 : 0,
    'contem_lactose': contemLactose ? 1 : 0,
    'vegano': vegano ? 1 : 0,
    'vegetariano': vegetariano ? 1 : 0,
    'apimentado': apimentado ? 1 : 0,
    'selos': selos,
    'disponivel_inicio': disponivelInicio,
    'disponivel_fim': disponivelFim,
    'disponivel_dias': disponivelDias,
    'tempo_preparo_min': tempoPreparoMin,
    'disponivel': disponivel ? 1 : 0,
    'estoque': estoque,
    'ordem': ordem,
    'ativo': ativo ? 1 : 0,
    'destaque': destaque ? 1 : 0,
  };

  ProdutoModel copyWith({
    int? id,
    int? lojaId,
    int? subcategoriaId,
    int? categoriaId,
    String? categoriaNome,
    String? tipo,
    String? nome,
    String? descricao,
    String? slug,
    double? preco,
    double? precoPromocional,
    String? imagem,
    List<String>? imagens,
    List<String>? ingredientes,
    String? ingredientesTexto,
    int? calorias,
    int? pesoGramas,
    bool? contemGluten,
    bool? contemLactose,
    bool? vegano,
    bool? vegetariano,
    bool? apimentado,
    List<String>? selos,
    String? disponivelInicio,
    String? disponivelFim,
    List<int>? disponivelDias,
    int? tempoPreparoMin,
    bool? disponivel,
    int? estoque,
    int? ordem,
    double? notaMedia,
    int? totalAvaliacoes,
    int? visualizacoes,
    int? cliques,
    bool? ativo,
    bool? destaque,
    String? criadoEm,
    String? atualizadoEm,
    String? deletadoEm,
  }) {
    return ProdutoModel(
      id: id ?? this.id,
      lojaId: lojaId ?? this.lojaId,
      subcategoriaId: subcategoriaId ?? this.subcategoriaId,
      categoriaId: categoriaId ?? this.categoriaId,
      categoriaNome: categoriaNome ?? this.categoriaNome,
      tipo: tipo ?? this.tipo,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      slug: slug ?? this.slug,
      preco: preco ?? this.preco,
      precoPromocional: precoPromocional ?? this.precoPromocional,
      imagem: imagem ?? this.imagem,
      imagens: imagens ?? this.imagens,
      ingredientes: ingredientes ?? this.ingredientes,
      ingredientesTexto: ingredientesTexto ?? this.ingredientesTexto,
      calorias: calorias ?? this.calorias,
      pesoGramas: pesoGramas ?? this.pesoGramas,
      contemGluten: contemGluten ?? this.contemGluten,
      contemLactose: contemLactose ?? this.contemLactose,
      vegano: vegano ?? this.vegano,
      vegetariano: vegetariano ?? this.vegetariano,
      apimentado: apimentado ?? this.apimentado,
      selos: selos ?? this.selos,
      disponivelInicio: disponivelInicio ?? this.disponivelInicio,
      disponivelFim: disponivelFim ?? this.disponivelFim,
      disponivelDias: disponivelDias ?? this.disponivelDias,
      tempoPreparoMin: tempoPreparoMin ?? this.tempoPreparoMin,
      disponivel: disponivel ?? this.disponivel,
      estoque: estoque ?? this.estoque,
      ordem: ordem ?? this.ordem,
      notaMedia: notaMedia ?? this.notaMedia,
      totalAvaliacoes: totalAvaliacoes ?? this.totalAvaliacoes,
      visualizacoes: visualizacoes ?? this.visualizacoes,
      cliques: cliques ?? this.cliques,
      ativo: ativo ?? this.ativo,
      destaque: destaque ?? this.destaque,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      deletadoEm: deletadoEm ?? this.deletadoEm,
    );
  }

  @override
  List<Object?> get props => [
    id, lojaId, subcategoriaId, categoriaId, categoriaNome, tipo, nome, descricao, slug, preco,
    precoPromocional, imagem, imagens, ingredientes, ingredientesTexto,
    calorias, pesoGramas, contemGluten, contemLactose, vegano, vegetariano,
    apimentado, selos, disponivelInicio, disponivelFim, disponivelDias,
    tempoPreparoMin, disponivel, estoque, ordem, notaMedia, totalAvaliacoes,
    visualizacoes, cliques, ativo, destaque, criadoEm, atualizadoEm, deletadoEm,
  ];
}
