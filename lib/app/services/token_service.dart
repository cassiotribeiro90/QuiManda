import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresInKey = 'expires_in';
  static const String _lojistaIdKey = 'lojista_id';
  static const String _lojistaNomeKey = 'lojista_nome';
  static const String _lojistaDataKey = 'lojista_data';
  static const String _storeIdKey = 'store_id';

  final SharedPreferences _prefs;
  final _storage = const FlutterSecureStorage();

  TokenService(this._prefs);

  // 🔥 1. SALVAR TOKENS
  Future<void> saveTokens(String accessToken, String refreshToken, {String? tokenType, int? expiresIn}) async {
    debugPrint('🔐 [TOKEN] Salvando tokens...');
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    
    if (tokenType != null) {
      await _storage.write(key: _tokenTypeKey, value: tokenType);
    }
    if (expiresIn != null) {
      await _storage.write(key: _expiresInKey, value: expiresIn.toString());
    }
    
    debugPrint('✅ [TOKEN] Tokens salvos com sucesso');
    debugPrint('   Access Token: ${accessToken.substring(0, 10)}...');
    debugPrint('   Refresh Token: ${refreshToken.substring(0, 10)}...');
  }

  // 🔥 2. OBTER ACCESS TOKEN
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // 🔥 3. OBTER REFRESH TOKEN
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // 🔥 4. VERIFICAR SE TEM TOKEN VÁLIDO
  Future<bool> hasValidToken() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final hasBoth = accessToken != null && accessToken.isNotEmpty && 
                    refreshToken != null && refreshToken.isNotEmpty;
    
    debugPrint('🔐 [TOKEN] Verificando tokens: access=${accessToken != null}, refresh=${refreshToken != null}');
    return hasBoth;
  }

  // 🔥 5. SALVAR APENAS ACCESS TOKEN (APÓS REFRESH)
  Future<void> saveAccessToken(String accessToken) async {
    debugPrint('🔐 [TOKEN] Salvando novo access token...');
    await _storage.write(key: _accessTokenKey, value: accessToken);
    debugPrint('✅ [TOKEN] Access token atualizado');
  }

  // 🔥 6. SALVAR DADOS DO LOJISTA
  Future<void> saveLojista(Map<String, dynamic> lojista) async {
    if (lojista['id'] != null) {
      await _prefs.setInt(_lojistaIdKey, lojista['id'] as int);
    }
    if (lojista['nome'] != null) {
      await _prefs.setString(_lojistaNomeKey, lojista['nome'] as String);
    }
    await _prefs.setString(_lojistaDataKey, jsonEncode(lojista));
  }

  int? getLojistaId() => _prefs.getInt(_lojistaIdKey);
  String? getLojistaNome() => _prefs.getString(_lojistaNomeKey);
  
  Map<String, dynamic>? getLojistaData() {
    final data = _prefs.getString(_lojistaDataKey);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // 🔥 7. LIMPAR TOKENS E DADOS
  Future<void> clear() async {
    debugPrint('🔐 [TOKEN] Limpando todos os tokens e dados...');
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenTypeKey);
    await _storage.delete(key: _expiresInKey);
    await _storage.delete(key: _storeIdKey);
    
    await _prefs.remove(_lojistaIdKey);
    await _prefs.remove(_lojistaNomeKey);
    await _prefs.remove(_lojistaDataKey);
    debugPrint('✅ [TOKEN] Dados removidos');
  }

  // 🔥 8. SALVAR STORE ID
  Future<void> saveStoreId(String storeId) async {
    await _storage.write(key: _storeIdKey, value: storeId);
  }

  Future<String?> getStoreId() async {
    return await _storage.read(key: _storeIdKey);
  }
}
