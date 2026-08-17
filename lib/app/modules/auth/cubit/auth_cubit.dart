import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../service/auth_service.dart';
import '../model/lojista_model.dart';
import '../../../services/token_service.dart';
import '../../../core/services/storage_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final TokenService _tokenService;
  final StorageService _storageService;
  
  AuthCubit(this._authService, this._tokenService, this._storageService) : super(AuthInitial());

  Future<void> checkAuth() async {
    final token = await _storageService.getToken();
    final lojistaId = _tokenService.getLojistaId();
    
    if (token != null && lojistaId != null) {
      try {
        final response = await _authService.getMe();
        if (response['success'] == true) {
          final lojista = LojistaModel.fromJson(response['data']['lojista']);
          emit(AuthAuthenticated(lojista, token));
          return;
        }
      } catch (_) {
        await logout();
      }
    }
    emit(AuthUnauthenticated());
  }

  Future<void> checkAuthStatus() async {
    final isLogged = await _storageService.isLoggedIn();
    if (isLogged) {
      final token = await _storageService.getToken();
      final lojistaData = _tokenService.getLojistaData();
      if (lojistaData != null && token != null) {
        final lojista = LojistaModel.fromJson(lojistaData);
        emit(AuthAuthenticated(lojista, token));
      } else {
        await checkAuth(); // Try to fetch from server if data is missing but token exists
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> sendOtp(String telefone) async {
    emit(AuthLoading());
    try {
      final telLimpo = telefone.replaceAll(RegExp(r'[^0-9]'), '');
      final response = await _authService.sendOtp(telLimpo);
      if (response['success'] == true) {
        final telefoneRetornado = response['data']?['telefone'] ?? telefone;
        emit(AuthPhoneSent(telefoneRetornado, 300));
      } else {
        emit(AuthError(response['message'] ?? 'Erro ao enviar código'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyOtp(String telefone, String codigo) async {
    emit(AuthOtpVerifying());
    try {
      final telLimpo = telefone.replaceAll(RegExp(r'[^0-9]'), '');
      final response = await _authService.verifyOtp(telLimpo, codigo);
      
      if (response['success'] == true) {
        final data = response['data'];
        final token = data['access_token'] as String;
        final refreshToken = data['refresh_token'] as String;
        final lojista = LojistaModel.fromJson(data['lojista']);

        await _storageService.saveToken(token);
        await _storageService.saveRefreshToken(refreshToken);
        await _tokenService.saveTokens(token, refreshToken);
        await _tokenService.saveLojista(data['lojista']);

        emit(AuthAuthenticated(lojista, token));
      } else {
        emit(AuthError(response['message'] ?? 'Código inválido'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String email, String senha) async {
    emit(AuthLoading());
    try {
      final response = await _authService.login(email, senha);
      if (response['success'] == true) {
        final data = response['data'];
        final token = data['access_token'] as String;
        final lojista = LojistaModel.fromJson(data['lojista']);

        await _storageService.saveToken(token);
        await _tokenService.saveTokens(token, ''); // ou refresh token se vier
        await _tokenService.saveLojista(data['lojista']);

        emit(AuthAuthenticated(lojista, token));
      } else {
        emit(AuthError(response['message'] ?? 'Email ou senha inválidos'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {}
    
    await _storageService.deleteTokens();
    await _tokenService.clear();
    emit(AuthUnauthenticated());
  }
}
