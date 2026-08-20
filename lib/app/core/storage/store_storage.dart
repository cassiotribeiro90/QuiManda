import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../modules/auth/model/loja_model.dart';

class StoreStorage {
  final SharedPreferences _prefs;
  static const String _keyStoreId = 'selected_store_id';
  static const String _keyStores = 'cached_stores';

  StoreStorage(this._prefs);

  Future<void> saveSelectedStoreId(int storeId) async {
    await _prefs.setInt(_keyStoreId, storeId);
    if (kDebugMode) {
      print('[STORE_STORAGE] Loja selecionada salva: $storeId');
    }
  }

  int? getSelectedStoreId() {
    final id = _prefs.getInt(_keyStoreId);
    if (kDebugMode) {
      print('[STORE_STORAGE] Loja selecionada recuperada: $id');
    }
    return id;
  }

  Future<void> saveStores(List<LojaModel> stores) async {
    final jsonList = stores.map((e) => e.toJson()).toList();
    await _prefs.setString(_keyStores, json.encode(jsonList));
    if (kDebugMode) {
      print('[STORE_STORAGE] Salvando ${stores.length} lojas no cache');
    }
  }

  List<LojaModel> getStores() {
    final jsonString = _prefs.getString(_keyStores);
    if (jsonString == null) {
      if (kDebugMode) {
        print('[STORE_STORAGE] Nenhuma loja em cache');
      }
      return [];
    }
    final List<dynamic> jsonList = json.decode(jsonString);
    final stores = jsonList.map((e) => LojaModel.fromJson(e as Map<String, dynamic>)).toList();
    if (kDebugMode) {
      print('[STORE_STORAGE] ${stores.length} lojas carregadas do cache');
    }
    return stores;
  }

  Future<void> clear() async {
    await _prefs.remove(_keyStoreId);
    await _prefs.remove(_keyStores);
    if (kDebugMode) {
      print('[STORE_STORAGE] Dados de loja limpos');
    }
  }
}
