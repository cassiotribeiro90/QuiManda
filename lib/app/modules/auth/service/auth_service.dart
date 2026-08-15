import '../../../core/api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Envia OTP para o telefone do lojista
  /// POST /api/lojista/auth-lojista/phone
  Future<Map<String, dynamic>> sendOtp(String telefone) async {
    final response = await _apiClient.dio.post(
      '/api/lojista/auth-lojista/phone',
      data: {'phone': telefone},
    );
    return response.data;
  }

  /// Verifica OTP e autentica o lojista
  /// POST /api/lojista/auth-lojista/verify-otp
  Future<Map<String, dynamic>> verifyOtp(String telefone, String codigo) async {
    final response = await _apiClient.dio.post(
      '/api/lojista/auth-lojista/verify-otp',
      data: {'phone': telefone, 'code': codigo},
    );
    return response.data;
  }

  /// Login com email e senha (fallback)
  /// POST /api/lojista/auth-lojista/login
  Future<Map<String, dynamic>> login(String email, String senha) async {
    final response = await _apiClient.dio.post(
      '/api/lojista/auth-lojista/login',
      data: {'email': email, 'senha': senha},
    );
    return response.data;
  }

  /// Refresh token
  /// POST /api/lojista/auth-lojista/refresh-token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _apiClient.dio.post(
      '/api/lojista/auth-lojista/refresh-token',
      data: {'refresh_token': refreshToken},
    );
    return response.data;
  }

  /// Logout
  /// POST /api/lojista/auth-lojista/logout
  Future<Map<String, dynamic>> logout() async {
    final response = await _apiClient.dio.post('/api/lojista/auth-lojista/logout');
    return response.data;
  }

  /// Busca dados do lojista autenticado
  /// GET /api/lojista/auth-lojista/me
  Future<Map<String, dynamic>> getMe() async {
    final response = await _apiClient.dio.get('/api/lojista/auth-lojista/me');
    return response.data;
  }

  /// Criar nova conta de lojista
  /// POST /api/lojista/auth-lojista/create
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post(
      '/api/lojista/auth-lojista/create',
      data: data,
    );
    return response.data;
  }
}
