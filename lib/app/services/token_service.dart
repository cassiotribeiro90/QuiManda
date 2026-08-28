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
    
    if (refreshToken.isEmpty) {
      debugPrint('⚠️ [TOKEN] AVISO: Refresh Token está vazio!');
    }

    if (kIsWeb) {
      await _prefs.setString(_accessTokenKey, accessToken);
      await _prefs.setString(_refreshTokenKey, refreshToken);
      if (tokenType != null) await _prefs.setString(_tokenTypeKey, tokenType);
      if (expiresIn != null) await _prefs.setString(_expiresInKey, expiresIn.toString());
    } else {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      if (tokenType != null) {
        await _storage.write(key: _tokenTypeKey, value: tokenType);
      }
      if (expiresIn != null) {
        await _storage.write(key: _expiresInKey, value: expiresIn.toString());
      }
    }
    
    // 🔥 VERIFICAÇÃO DE SALVAMENTO (Especialmente para Web)
    final savedRefresh = await getRefreshToken();
    debugPrint('✅ [TOKEN] Tokens salvos. Refresh detectado: ${savedRefresh != null ? 'SIM' : 'NÃO'}');
  }

  // 🔥 2. OBTER ACCESS TOKEN
  Future<String?> getAccessToken() async {
    if (kIsWeb) return _prefs.getString(_accessTokenKey);
    return await _storage.read(key: _accessTokenKey);
  }

  // 🔥 3. OBTER REFRESH TOKEN
  Future<String?> getRefreshToken() async {
    if (kIsWeb) return _prefs.getString(_refreshTokenKey);
    return await _storage.read(key: _refreshTokenKey);
  }

  // 🔥 4. VERIFICAR SE TEM TOKEN VÁLIDO
  Future<bool> hasValidToken() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final hasBoth = accessToken != null && accessToken.isNotEmpty && 
                    refreshToken != null && refreshToken.isNotEmpty;
    
    debugPrint('🔐 [TOKEN] Status: access=${accessToken != null}, refresh=${refreshToken != null}');
    return hasBoth;
  }

  // 🔥 5. SALVAR APENAS ACCESS TOKEN (APÓS REFRESH)
  Future<void> saveAccessToken(String accessToken) async {
    debugPrint('🔐 [TOKEN] Atualizando access token...');
    if (kIsWeb) {
      await _prefs.setString(_accessTokenKey, accessToken);
    } else {
      await _storage.write(key: _accessTokenKey, value: accessToken);
    }
    debugPrint('✅ [TOKEN] Access token atualizado');
  }

  // 🔥 6. SALVAR DADOS DO LOJISTA
  Future<void> saveLojista(Map<String, dynamic> lojista) async {
    debugPrint('🔐 [TOKEN] Salvando dados do lojista no SharedPreferences');
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
    if (kIsWeb) {
      await _prefs.remove(_accessTokenKey);
      await _prefs.remove(_refreshTokenKey);
      await _prefs.remove(_tokenTypeKey);
      await _prefs.remove(_expiresInKey);
      await _prefs.remove(_storeIdKey);
    } else {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _tokenTypeKey);
      await _storage.delete(key: _expiresInKey);
      await _storage.delete(key: _storeIdKey);
    }
    
    await _prefs.remove(_lojistaIdKey);
    await _prefs.remove(_lojistaNomeKey);
    await _prefs.remove(_lojistaDataKey);
    debugPrint('✅ [TOKEN] Todos os dados removidos localmente');
  }

  // 🔥 Mantido para compatibilidade
  Future<void> clearAll() async {
    await clear();
  }

  // 🔥 8. SALVAR STORE ID
  Future<void> saveStoreId(String storeId) async {
    if (kIsWeb) {
      await _prefs.setString(_storeIdKey, storeId);
    } else {
      await _storage.write(key: _storeIdKey, value: storeId);
    }
  }

  Future<String?> getStoreId() async {
    if (kIsWeb) return _prefs.getString(_storeIdKey);
    return await _storage.read(key: _storeIdKey);
  }
}
