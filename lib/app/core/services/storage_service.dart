import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _onboardingKey = 'onboarding_shown';
  
  final _secureStorage = const FlutterSecureStorage();
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Salvar token
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  // Recuperar token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Salvar refresh token
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // Remover tokens (logout)
  Future<void> deleteTokens() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  // Salvar ID do usuário
  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  Future<String?> getUserId() async {
    return _prefs.getString(_userIdKey);
  }

  // Onboarding
  Future<void> setOnboardingShown() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  Future<bool> isOnboardingShown() async {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> clearAll() async {
    await deleteTokens();
    await _prefs.remove(_userIdKey);
    // onboarding we usually keep if we want it to be shown only once ever
  }
  
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
