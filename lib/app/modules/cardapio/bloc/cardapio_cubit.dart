import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/produto_model.dart';
import '../models/subcategoria.dart';
import '../repositories/cardapio_repository.dart';
import 'cardapio_state.dart';

class CardapioCubit extends Cubit<CardapioState> {
  final CardapioRepository repository;

  CardapioCubit(this.repository) : super(CardapioInitial());

  Map<String, List<ProdutoModel>> get produtosAgrupados {
    final current = state;
    List<ProdutoModel> produtos = [];
    if (current is CardapioLoaded) {
      produtos = current.produtos;
    } else if (current is CardapioOperationSuccess && current.produtos != null) {
      produtos = current.produtos!;
    } else if (current is CardapioFormLoaded && current.produtos != null) {
      produtos = current.produtos!;
    }
    
    if (produtos.isEmpty) return {};

    return produtos.fold<Map<String, List<ProdutoModel>>>({}, (map, produto) {
      final key = produto.categoriaNome ?? 'Sem categoria';
      if (!map.containsKey(key)) map[key] = [];
      map[key]!.add(produto);
      return map;
    });
  }

  Future<void> carregarProdutos() async {
    debugPrint('🔄 [CardapioCubit] Carregando produtos...');
    emit(CardapioLoading());
    try {
      final produtos = await repository.listar();
      debugPrint('✅ [CardapioCubit] Produtos carregados: ${produtos.length}');
      emit(CardapioLoaded(produtos));
    } catch (e, stackTrace) {
      debugPrint('❌ [CardapioCubit] Erro ao carregar: $e');
      debugPrint('📚 StackTrace: $stackTrace');
      emit(CardapioError('Erro ao carregar cardápio. Tente novamente.'));
    }
  }

  Future<void> loadInitialData({int? produtoId}) async {
    debugPrint('🔄 [CardapioCubit] Carregando dados iniciais...');
    
    // Preserve existing list if any
    List<ProdutoModel>? currentProducts;
    if (state is CardapioLoaded) {
      currentProducts = (state as CardapioLoaded).produtos;
    } else if (state is CardapioFormLoaded) {
      currentProducts = (state as CardapioFormLoaded).produtos;
    }

    emit(CardapioLoading());
    try {
      final categorias = await repository.listarCategorias();
      ProdutoModel? produto;
      List<Subcategoria> subcategorias = [];
      
      if (produtoId != null) {
        produto = await repository.visualizar(produtoId);
        debugPrint('📦 [CardapioCubit] Produto carregado: ${produto.toJson()}');
        
        if (produto.categoriaId != null) {
          subcategorias = await repository.listarSubcategorias(produto.categoriaId!);
        }
      }
      
      emit(CardapioFormLoaded(
        categorias: categorias,
        subcategorias: subcategorias,
        produto: produto,
        produtos: currentProducts,
      ));
    } catch (e, stackTrace) {
      debugPrint('❌ [CardapioCubit] Erro ao carregar dados iniciais: $e');
      debugPrint('📚 StackTrace: $stackTrace');
      emit(CardapioError('Erro ao carregar dados do formulário.'));
    }
  }

  Future<List<Subcategoria>> loadSubcategorias(int categoriaId) async {
    final current = state;
    if (current is CardapioFormLoaded) {
      try {
        debugPrint('🔄 [CardapioCubit] Carregando subcategorias para categoria: $categoriaId');
        final subcategorias = await repository.listarSubcategorias(categoriaId);
        emit(current.copyWith(subcategorias: subcategorias));
        return subcategorias;
      } catch (e, stackTrace) {
        debugPrint('❌ [CardapioCubit] Erro ao carregar subcategorias: $e');
        debugPrint('📚 StackTrace: $stackTrace');
        emit(CardapioError('Erro ao carregar subcategorias.'));
      }
    }
    return [];
  }

  Future<bool> saveProduto(Map<String, dynamic> data, {int? id}) async {
    debugPrint('🔄 [CardapioCubit] Salvando produto...');
    emit(CardapioOperationLoading());
    try {
      final produto = ProdutoModel.fromJson(data);
      if (id == null) {
        await repository.criar(produto);
      } else {
        await repository.atualizar(id, produto);
      }
      
      final produtos = await repository.listar();
      emit(CardapioOperationSuccess(
        id == null ? 'Produto criado com sucesso!' : 'Produto atualizado com sucesso!',
        produtos: produtos,
      ));
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [CardapioCubit] Erro ao salvar produto: $e');
      debugPrint('📚 StackTrace: $stackTrace');
      emit(CardapioError('Erro ao salvar produto.'));
      return false;
    }
  }

  Future<bool> deleteProduto(int id) async {
    debugPrint('🔄 [CardapioCubit] Removendo produto $id...');
    emit(CardapioOperationLoading());
    try {
      await repository.deletar(id);
      final produtos = await repository.listar();
      emit(CardapioOperationSuccess('Produto removido com sucesso!', produtos: produtos));
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [CardapioCubit] Erro ao remover produto: $e');
      debugPrint('📚 StackTrace: $stackTrace');
      emit(CardapioError('Erro ao remover produto.'));
      return false;
    }
  }

  Future<void> alternarDisponibilidade(int id, bool disponivel) async {
    try {
      debugPrint('🔄 [CardapioCubit] Alterando disponibilidade produto $id para $disponivel');
      final atualizado = await repository.toggleDisponibilidade(id, disponivel);
      final current = state;
      List<ProdutoModel> currentList = [];
      
      if (current is CardapioLoaded) {
        currentList = List<ProdutoModel>.from(current.produtos);
      } else if (current is CardapioOperationSuccess && current.produtos != null) {
        currentList = List<ProdutoModel>.from(current.produtos!);
      }

      if (currentList.isNotEmpty) {
        final index = currentList.indexWhere((p) => p.id == id);
        if (index != -1) {
          currentList[index] = atualizado;
          emit(CardapioLoaded(currentList));
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [CardapioCubit] Erro ao alternar status: $e');
      debugPrint('📚 StackTrace: $stackTrace');
      emit(CardapioError('Erro ao alterar disponibilidade.'));
    }
  }

  Future<void> atualizarEstoque(int id, int? quantidade) async {
    try {
      debugPrint('🔄 [CardapioCubit] Atualizando estoque produto $id para $quantidade');
      final atualizado = await repository.atualizarEstoque(id, quantidade);
      final current = state;
      List<ProdutoModel> currentList = [];
      
      if (current is CardapioLoaded) {
        currentList = List<ProdutoModel>.from(current.produtos);
      } else if (current is CardapioOperationSuccess && current.produtos != null) {
        currentList = List<ProdutoModel>.from(current.produtos!);
      }

      if (currentList.isNotEmpty) {
        final index = currentList.indexWhere((p) => p.id == id);
        if (index != -1) {
          currentList[index] = atualizado;
          emit(CardapioLoaded(currentList));
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [CardapioCubit] Erro ao atualizar estoque: $e');
      debugPrint('📚 StackTrace: $stackTrace');
      emit(CardapioError('Erro ao atualizar estoque.'));
    }
  }
}
