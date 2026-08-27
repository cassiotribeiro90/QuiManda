import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class StoreStorage {
  static const String _selectedStoreIdKey = 'selected_store_id';
  static const String _storesKey = 'stores';
  final SharedPreferences _prefs;

  // 🔥 Construtor que recebe SharedPreferences
  StoreStorage(this._prefs);

  // 🔥 Metodo estático para criar instância (async)
  static Future<StoreStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StoreStorage(prefs);
  }

  // ==================== MÉTODOS PARA STORE ====================

  /// Salva a lista de lojas
  Future<void> saveStores(List<Map<String, dynamic>> stores) async {
    final jsonString = jsonEncode(stores);
    await _prefs.setString(_storesKey, jsonString);
    debugPrint('🏪 [STORE_STORAGE] Lojas salvas: ${stores.length}');
  }

  /// Recupera a lista de lojas
  List<Map<String, dynamic>>? getStores() {
    final jsonString = _prefs.getString(_storesKey);
    if (jsonString == null) return null;
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('⚠️ [STORE_STORAGE] Erro ao decodificar lojas: $e');
      return null;
    }
  }

  /// Salva o ID da loja selecionada
  Future<void> saveSelectedStoreId(int storeId) async {
    await _prefs.setInt(_selectedStoreIdKey, storeId);
    debugPrint('🏪 [STORE_STORAGE] Loja selecionada salva: $storeId');
  }

  /// Recupera o ID da loja selecionada
  int? getSelectedStoreId() {
    return _prefs.getInt(_selectedStoreIdKey);
  }

  /// Limpa todos os dados do storage
  Future<void> clear() async {
    debugPrint('🏪 [STORE_STORAGE] 🧹 Limpando dados...');
    await _prefs.remove(_selectedStoreIdKey);
    await _prefs.remove(_storesKey);
    debugPrint('🏪 [STORE_STORAGE] ✅ Dados removidos');
  }

  /// Limpa apenas o ID da loja selecionada
  Future<void> clearSelectedStoreId() async {
    await _prefs.remove(_selectedStoreIdKey);
    debugPrint('🏪 [STORE_STORAGE] Loja selecionada removida');
  }
}
