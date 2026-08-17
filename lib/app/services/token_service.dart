import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String accessTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String lojistaIdKey = 'lojista_id';
  static const String lojistaNomeKey = 'lojista_nome';
  static const String lojistaDataKey = 'lojista_data';

  final SharedPreferences _prefs;

  TokenService(this._prefs);

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _prefs.setString(accessTokenKey, accessToken);
    await _prefs.setString(refreshTokenKey, refreshToken);
  }

  Future<void> saveLojista(Map<String, dynamic> lojista) async {
    await _prefs.setInt(lojistaIdKey, lojista['id'] as int);
    await _prefs.setString(lojistaNomeKey, lojista['nome'] as String);
    await _prefs.setString(lojistaDataKey, jsonEncode(lojista));
  }

  String? getAccessToken() => _prefs.getString(accessTokenKey);
  String? getRefreshToken() => _prefs.getString(refreshTokenKey);
  int? getLojistaId() => _prefs.getInt(lojistaIdKey);
  String? getLojistaNome() => _prefs.getString(lojistaNomeKey);
  
  Map<String, dynamic>? getLojistaData() {
    final data = _prefs.getString(lojistaDataKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> clear() async {
    await _prefs.remove(accessTokenKey);
    await _prefs.remove(refreshTokenKey);
    await _prefs.remove(lojistaIdKey);
    await _prefs.remove(lojistaNomeKey);
    await _prefs.remove(lojistaDataKey);
  }

  bool hasToken() => _prefs.containsKey(accessTokenKey);

  Future<bool> refreshTokens(Dio dio) async {
    try {
      final refreshToken = getRefreshToken();
      if (refreshToken == null) return false;

      final response = await dio.post(
        '/api/lojista/auth-lojista/refresh-token',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];
        
        await saveTokens(newAccessToken, newRefreshToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
