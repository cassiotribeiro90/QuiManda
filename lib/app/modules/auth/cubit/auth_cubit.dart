import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../service/auth_service.dart';
import '../model/lojista_model.dart';
import '../../../services/token_service.dart';
import '../../../core/services/storage_service.dart';

import '../../../di/dependencies.dart';
import '../../store/bloc/store_cubit.dart';
import '../model/auth_response_model.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/services/device_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final TokenService _tokenService;
  final StorageService _storageService;
  final FcmService _fcmService;
  final DeviceService _deviceService;
  
  AuthCubit({
    required AuthService authService,
    required TokenService tokenService,
    required StorageService storageService,
    required FcmService fcmService,
    required DeviceService deviceService,
  }) : _authService = authService,
       _tokenService = tokenService,
       _storageService = storageService,
       _fcmService = fcmService,
       _deviceService = deviceService,
       super(AuthInitial());

  Future<void> checkAuthStatus() async {
    final token = await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      final lojistaData = _tokenService.getLojistaData();
      if (lojistaData != null) {
        final lojista = LojistaModel.fromJson(lojistaData);
        // Carrega as lojas antes de emitir autenticado
        await getIt<StoreCubit>().loadStores();
        emit(AuthAuthenticated(lojista, token));
      } else {
        // Token existe mas dados da loja não. Busca do servidor.
        await checkAuth();
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> checkAuth() async {
    final token = await _storageService.getToken();
    
    if (token != null && token.isNotEmpty) {
      try {
        final response = await _authService.getMe();
        if (response['success'] == true) {
          final data = response['data'];
          final lojista = LojistaModel.fromJson(data['lojista']);
          // Salva localmente para a próxima vez
          await _tokenService.saveLojista(data['lojista']);
          
          final authData = AuthResponse.fromJson(response);
          await getIt<StoreCubit>().updateStores(authData.lojas);
          
          emit(AuthAuthenticated(lojista, token));
          return;
        }
      } catch (e) {
        debugPrint('❌ Erro ao validar token: $e');
        if (e.toString().contains('401')) {
           await logout();
        }
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
      print('[AUTH_CUBIT] Verificando OTP para $telefone');
      final telLimpo = telefone.replaceAll(RegExp(r'[^0-9]'), '');
      
      // 🔥 OBTÉM O FCM TOKEN
      final fcmToken = _fcmService.token;
      
      // 🔥 OBTÉM O DEVICE ID
      final deviceId = await _deviceService.getDeviceId();

      final response = await _authService.verifyOtp(telLimpo, codigo, deviceId: deviceId, deviceToken: fcmToken);
      
      if (response['success'] == true) {
        print('[AUTH_CUBIT] OTP verificado com sucesso');
        final authData = AuthResponse.fromJson(response);
        final token = authData.accessToken!;
        final refreshToken = authData.refreshToken!;
        final lojista = authData.lojista!;

        await _storageService.saveToken(token);
        await _storageService.saveRefreshToken(refreshToken);
        await _storageService.saveUserData(response['data']['lojista']);
        await _tokenService.saveTokens(token, refreshToken);
        await _tokenService.saveLojista(response['data']['lojista']);

        // 🔥 ENVIA DEVICE TOKEN (garantia se não foi no request inicial)
        await _fcmService.sendTokenToBackend();

        print('[AUTH_CUBIT] Dados de autenticação salvos. Lojas recebidas: ${authData.lojas.length}');

        // 🔥 ATUALIZA AS LOJAS NO CUBIT
        await getIt<StoreCubit>().updateStores(authData.lojas);

        emit(AuthAuthenticated(lojista, token));
      } else {
        print('[AUTH_CUBIT] Erro na verificação do OTP: ${response['message']}');
        emit(AuthError(response['message'] ?? 'Código inválido'));
      }
    } catch (e) {
      print('[AUTH_CUBIT] Exceção no verifyOtp: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String email, String senha) async {
    emit(AuthLoading());
    try {
      print('[AUTH_CUBIT] Tentando login para $email');
      
      // 🔥 OBTÉM O FCM TOKEN
      final fcmToken = _fcmService.token;

      // 🔥 OBTÉM O DEVICE ID
      final deviceId = await _deviceService.getDeviceId();

      final response = await _authService.login(email, senha, deviceId: deviceId, deviceToken: fcmToken);
      if (response['success'] == true) {
        print('[AUTH_CUBIT] Login bem-sucedido');
        final authData = AuthResponse.fromJson(response);
        final token = authData.accessToken!;
        final refreshToken = authData.refreshToken;
        final lojista = authData.lojista!;

        await _storageService.saveToken(token);
        if (refreshToken != null) {
          await _storageService.saveRefreshToken(refreshToken);
        }
        await _storageService.saveUserData(response['data']['lojista']);
        await _tokenService.saveTokens(token, refreshToken ?? '');
        await _tokenService.saveLojista(response['data']['lojista']);

        // 🔥 ENVIA DEVICE TOKEN (garantia)
        await _fcmService.sendTokenToBackend();

        print('[AUTH_CUBIT] Dados de login salvos. Lojas recebidas: ${authData.lojas.length}');

        // 🔥 ATUALIZA AS LOJAS NO CUBIT
        await getIt<StoreCubit>().updateStores(authData.lojas);

        emit(AuthAuthenticated(lojista, token));
      } else {
        print('[AUTH_CUBIT] Falha no login: ${response['message']}');
        emit(AuthError(response['message'] ?? 'Email ou senha inválidos'));
      }
    } catch (e) {
      print('[AUTH_CUBIT] Exceção no login: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      // 🔥 REMOVE O DEVICE TOKEN DO BACKEND
      await _fcmService.removeTokenFromBackend();
      await _authService.logout();
    } catch (_) {}
    
    // 🔥 LIMPA O DEVICE_ID LOCAL
    await _deviceService.clearDeviceId();
    await _storageService.clearAll();
    await _tokenService.clear();
    await getIt<StoreCubit>().clear();
    emit(AuthUnauthenticated());
  }
}
