import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'store_state.dart';
import '../../../core/storage/store_storage.dart';
import '../../auth/model/loja_model.dart';

class StoreCubit extends Cubit<StoreState> {
  final StoreStorage _storage;

  StoreCubit(this._storage) : super(const StoreInitial());

  // Carrega a loja salva e a lista de lojas
  Future<void> loadStores() async {
    debugPrint('🏪 [STORE] loadStores iniciado');
    emit(const StoreLoading());
    try {
      final stores = _storage.getStores();
      final selectedId = _storage.getSelectedStoreId();
      
      if (stores.isEmpty) {
        debugPrint('⚠️ [STORE] Nenhuma loja encontrada');
        emit(const StoreEmpty());
        return;
      }

      debugPrint('✅ [STORE] Lojas carregadas: ${stores.length}, ID selecionado: $selectedId');

      // Se não houver loja selecionada, seleciona a primeira
      int? effectiveSelectedId = selectedId;
      if (effectiveSelectedId == null || !stores.any((s) => s.id == effectiveSelectedId)) {
        effectiveSelectedId = stores.first.id;
        debugPrint('🏪 [STORE] Selecionando loja padrão: $effectiveSelectedId');
        await _storage.saveSelectedStoreId(effectiveSelectedId);
      }

      final selectedStore = stores.firstWhere((s) => s.id == effectiveSelectedId);
      debugPrint('🏪 [STORE] Loja ativa: ${selectedStore.nome}');
      
      emit(StoreLoaded(
        stores: stores,
        selectedStore: selectedStore,
        hasMultipleStores: stores.length > 1,
      ));
    } catch (e) {
      debugPrint('❌ [STORE] Erro ao carregar lojas: $e');
      emit(StoreError(e.toString()));
    }
  }

  // Troca a loja selecionada
  Future<void> selectStore(int storeId) async {
    debugPrint('🏪 [STORE] Selecionando loja ID: $storeId');
    if (state is! StoreLoaded) return;
    final currentState = state as StoreLoaded;
    
    // Se já é a loja selecionada, não faz nada
    if (currentState.selectedStore.id == storeId) return;

    final store = currentState.stores.firstWhere((s) => s.id == storeId);
    
    await _storage.saveSelectedStoreId(storeId);
    debugPrint('🏪 [STORE] Nova loja selecionada: ${store.nome}');
    
    // 🔥 EMITE O NOVO ESTADO COM A LOJA SELECIONADA E FLAG DE MUDANÇA
    emit(currentState.copyWith(
      selectedStore: store,
      storeChanged: true,
    ));

    // 🔥 Pequeno delay para garantir que o estado foi atualizado e ouvido
    await Future.delayed(const Duration(milliseconds: 100));
    
    // 🔥 Volta a flag para false após a mudança
    if (state is StoreLoaded) {
      emit((state as StoreLoaded).copyWith(storeChanged: false));
    }
  }

  // ... (hasStoreChanged) ...

  // Atualiza a lista de lojas (usado após login/refresh)
  Future<void> updateStores(List<LojaModel> stores, {int? selectedId}) async {
    debugPrint('🔄 [STORE] Atualizando lista com ${stores.length} lojas');
    await _storage.saveStores(stores);
    
    if (stores.isEmpty) {
      debugPrint('⚠️ [STORE] Lista de lojas vazia no update');
      emit(const StoreEmpty());
      return;
    }

    int? effectiveSelectedId = selectedId ?? 
        (state is StoreLoaded ? (state as StoreLoaded).selectedStore.id : stores.first.id);
    
    if (!stores.any((s) => s.id == effectiveSelectedId)) {
      effectiveSelectedId = stores.first.id;
    }
    
    debugPrint('💾 [STORE] Salvando loja selecionada no update: $effectiveSelectedId');
    await _storage.saveSelectedStoreId(effectiveSelectedId);

    final selectedStore = stores.firstWhere((s) => s.id == effectiveSelectedId);
    emit(StoreLoaded(
      stores: stores,
      selectedStore: selectedStore,
      hasMultipleStores: stores.length > 1,
    ));
  }

  // Limpa os dados (logout)
  Future<void> clear() async {
    await _storage.clear();
    emit(const StoreInitial());
  }
}
