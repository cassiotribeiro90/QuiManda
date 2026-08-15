import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_state.dart';
import '../service/auth_service.dart';
import '../model/lojista_model.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  AuthCubit(this._authService) : super(AuthInitial());

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final lojistaId = prefs.getInt('lojista_id');
    
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

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('refresh_token', refreshToken);
        await prefs.setInt('lojista_id', lojista.id);
        await prefs.setString('lojista_nome', lojista.nome);

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

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setInt('lojista_id', lojista.id);

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
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('lojista_id');
    await prefs.remove('lojista_nome');
    emit(AuthUnauthenticated());
  }
}
