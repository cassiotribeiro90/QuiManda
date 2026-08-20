import 'package:flutter_bloc/flutter_bloc.dart';
import 'store_state.dart';
import '../../../core/storage/store_storage.dart';
import '../../auth/model/loja_model.dart';

class StoreCubit extends Cubit<StoreState> {
  final StoreStorage _storage;

  StoreCubit(this._storage) : super(const StoreInitial());

  // Carrega a loja salva e a lista de lojas
  Future<void> loadStores() async {
    print('[STORE_CUBIT] loadStores iniciado');
    emit(const StoreLoading());
    try {
      final stores = _storage.getStores();
      final selectedId = _storage.getSelectedStoreId();
      
      if (stores.isEmpty) {
        print('[STORE_CUBIT] Nenhuma loja encontrada');
        emit(const StoreEmpty());
        return;
      }

      print('[STORE_CUBIT] Lojas carregadas: ${stores.length}, ID selecionado no storage: $selectedId');

      // Se não houver loja selecionada, seleciona a primeira
      int? effectiveSelectedId = selectedId;
      if (effectiveSelectedId == null || !stores.any((s) => s.id == effectiveSelectedId)) {
        effectiveSelectedId = stores.first.id;
        print('[STORE_CUBIT] Selecionando loja padrão (primeira da lista): $effectiveSelectedId');
        await _storage.saveSelectedStoreId(effectiveSelectedId);
      }

      final selectedStore = stores.firstWhere((s) => s.id == effectiveSelectedId);
      print('[STORE_CUBIT] Loja ativa: ${selectedStore.nome}');
      
      emit(StoreLoaded(
        stores: stores,
        selectedStore: selectedStore,
        hasMultipleStores: stores.length > 1,
      ));
    } catch (e) {
      print('[STORE_CUBIT] Erro ao carregar lojas: $e');
      emit(StoreError(e.toString()));
    }
  }

  // Troca a loja selecionada
  Future<void> selectStore(int storeId) async {
    print('[STORE_CUBIT] selectStore chamado para ID: $storeId');
    if (state is! StoreLoaded) return;
    final currentState = state as StoreLoaded;
    final store = currentState.stores.firstWhere((s) => s.id == storeId);
    
    await _storage.saveSelectedStoreId(storeId);
    print('[STORE_CUBIT] Nova loja selecionada: ${store.nome}');
    emit(currentState.copyWith(selectedStore: store));
  }

  // Atualiza a lista de lojas (usado após login/refresh)
  Future<void> updateStores(List<LojaModel> stores, {int? selectedId}) async {
    print('[STORE_CUBIT] updateStores chamado com ${stores.length} lojas');
    await _storage.saveStores(stores);
    
    if (stores.isEmpty) {
      print('[STORE_CUBIT] Lista de lojas vazia no update');
      emit(const StoreEmpty());
      return;
    }

    int? effectiveSelectedId = selectedId ?? 
        (state is StoreLoaded ? (state as StoreLoaded).selectedStore.id : stores.first.id);
    
    if (!stores.any((s) => s.id == effectiveSelectedId)) {
      effectiveSelectedId = stores.first.id;
    }
    
    print('[STORE_CUBIT] Salvando loja selecionada no update: $effectiveSelectedId');
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
