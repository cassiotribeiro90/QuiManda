import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/token_service.dart';
import '../../../core/storage/store_storage.dart';

class AuthService {
  final TokenService _tokenService;
  final StoreStorage _storeStorage;
  late final ApiClient _apiClient;

  AuthService(this._tokenService, this._storeStorage) {
    _apiClient = ApiClient(_tokenService, _storeStorage, addInterceptors: false);
  }

  /// Envia OTP para o telefone do lojista
  Future<Map<String, dynamic>> sendOtp(String telefone) async {
    final response = await _apiClient.dio.post(
      '/api/lojista/auth-lojista/phone',
      data: {'phone': telefone},
    );
    return response.data;
  }

  /// Verifica OTP e autentica o lojista
  Future<Map<String, dynamic>> verifyOtp(String telefone, String codigo, {String? deviceId, String? deviceToken}) async {
    final data = {
      'phone': telefone,
      'code': codigo,
    };
    if (deviceId != null) {
      data['device_id'] = deviceId;
    }
    if (deviceToken != null) {
      data['device_token'] = deviceToken;
    }
    final response = await _apiClient.dio.post(
      '/api/lojista/auth-lojista/verify-otp',
      data: data,
    );
    return response.data;
  }

  /// Login com email e senha (fallback)
  Future<Map<String, dynamic>> login(String email, String senha, {String? deviceId, String? deviceToken}) async {
    final data = {
      'email': email,
      'senha': senha,
    };
    if (deviceId != null) {
      data['device_id'] = deviceId;
    }
    if (deviceToken != null) {
      data['device_token'] = deviceToken;
    }
    final response = await _apiClient.dio.post(
      '/api/lojista/auth-lojista/login',
      data: data,
    );
    return response.data;
  }

  /// Refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    debugPrint('🔄 [AUTH_SERVICE] Chamando refresh-token...');
    try {
      // 🔥 Usa um Dio separado SEM interceptors para evitar loop
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ));

      final response = await dio.post(
        '/api/lojista/auth-lojista/refresh-token',
        data: {'refresh_token': refreshToken},
        options: Options(
          // 🔥 Remove o Authorization header para evitar loop
          headers: {
            'Authorization': null,
          },
        ),
      );

      debugPrint('✅ [AUTH_SERVICE] Resposta do refresh-token recebida');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ [AUTH_SERVICE] Erro na chamada de refresh-token: $e');
      rethrow;
    }
  }

  /// Logout
  Future<Map<String, dynamic>> logout() async {
    final response = await _apiClient.dio.post('/api/lojista/auth-lojista/logout');
    return response.data;
  }

  /// Busca dados do lojista autenticado
  Future<Map<String, dynamic>> getMe() async {
    final response = await _apiClient.dio.get('/api/lojista/auth-lojista/me');
    return response.data;
  }

  /// Criar nova conta de lojista
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post(
      '/api/lojista/auth-lojista/create',
      data: data,
    );
    return response.data;
  }

  /// Metodo para fazer logout forçado (apenas local)
  Future<void> forceLogout() async {
    debugPrint('🔐 [AUTH] Forçando logout local...');
    await _tokenService.clear();
    await _storeStorage.clear();
  }
}
