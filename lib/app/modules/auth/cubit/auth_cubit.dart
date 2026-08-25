import 'dart:io';
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
       super(AuthInitial()) {
    debugPrint('🔐 [AUTH] Cubit inicializado');
  }

  Future<void> checkAuthStatus() async {
    debugPrint('🚀 [AUTH] Checando status de autenticação...');
    // ⚠️ Aguarda um pequeno delay para garantir que a UI e o Router estão prontos
    await Future.delayed(const Duration(milliseconds: 200));

    final token = await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      debugPrint('🔐 [AUTH] Token encontrado localmente');
      final lojistaData = _tokenService.getLojistaData();
      if (lojistaData != null) {
        final lojista = LojistaModel.fromJson(lojistaData);
        debugPrint('✅ [AUTH] Lojista recuperado do storage: ${lojista.nome}');
        // Carrega as lojas antes de emitir autenticado
        await getIt<StoreCubit>().loadStores();
        emit(AuthAuthenticated(lojista, token));
      } else {
        debugPrint('⚠️ [AUTH] Token existe mas dados do lojista não. Validando no servidor...');
        await checkAuth();
      }
    } else {
      debugPrint('❌ [AUTH] Nenhum token encontrado');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> checkAuth() async {
    debugPrint('🚀 [AUTH] Validando token com o servidor...');
    final token = await _storageService.getToken();
    
    if (token != null && token.isNotEmpty) {
      try {
        final response = await _authService.getMe();
        if (response['success'] == true) {
          final data = response['data'];
          final lojista = LojistaModel.fromJson(data['lojista']);
          debugPrint('✅ [AUTH] Token válido. Lojista: ${lojista.nome}');
          
          await _tokenService.saveLojista(data['lojista']);
          final authData = AuthResponse.fromJson(response);
          await getIt<StoreCubit>().updateStores(authData.lojas);
          
          emit(AuthAuthenticated(lojista, token));
          return;
        }
      } catch (e) {
        debugPrint('❌ [AUTH] Erro ao validar token: $e');
        if (e.toString().contains('401')) {
           await logout();
        }
      }
    }
    emit(AuthUnauthenticated());
  }

  Future<void> sendOtp(String telefone) async {
    debugPrint('🔐 [AUTH] Solicitando OTP para: $telefone');
    emit(AuthLoading());
    try {
      final telLimpo = telefone.replaceAll(RegExp(r'[^0-9]'), '');
      final response = await _authService.sendOtp(telLimpo);
      if (response['success'] == true) {
        final telefoneRetornado = response['data']?['telefone'] ?? telefone;
        debugPrint('✅ [AUTH] OTP enviado com sucesso para: $telefoneRetornado');
        emit(AuthPhoneSent(telefoneRetornado, 300));
      } else {
        debugPrint('❌ [AUTH] Erro ao enviar OTP: ${response['message']}');
        emit(AuthError(response['message'] ?? 'Erro ao enviar código'));
      }
    } catch (e) {
      debugPrint('❌ [AUTH] Exceção ao enviar OTP: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyOtp(String telefone, String codigo) async {
    debugPrint('🔐 [AUTH] Verificando OTP para: $telefone');
    emit(AuthOtpVerifying());
    try {
      final telLimpo = telefone.replaceAll(RegExp(r'[^0-9]'), '');
      
      String? fcmToken;
      if (kIsWeb || !Platform.isWindows) {
        fcmToken = _fcmService.token;
      }
      
      final deviceId = await _deviceService.getDeviceId();

      final response = await _authService.verifyOtp(telLimpo, codigo, deviceId: deviceId, deviceToken: fcmToken);
      
      if (response['success'] == true) {
        debugPrint('✅ [AUTH] OTP verificado com sucesso');
        final authData = AuthResponse.fromJson(response);
        final token = authData.accessToken!;
        final refreshToken = authData.refreshToken!;
        final lojista = authData.lojista!;

        await _storageService.saveToken(token);
        await _storageService.saveRefreshToken(refreshToken);
        await _storageService.saveUserData(response['data']['lojista']);
        await _tokenService.saveTokens(token, refreshToken);
        await _tokenService.saveLojista(response['data']['lojista']);

        await _fcmService.sendTokenToBackend();
        await getIt<StoreCubit>().updateStores(authData.lojas);

        emit(AuthAuthenticated(lojista, token));
      } else {
        debugPrint('❌ [AUTH] Código OTP inválido: ${response['message']}');
        emit(AuthError(response['message'] ?? 'Código inválido'));
      }
    } catch (e) {
      debugPrint('❌ [AUTH] Exceção ao verificar OTP: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String email, String senha) async {
    debugPrint('🔐 [AUTH] Tentando login (E-mail): $email');
    emit(AuthLoading());
    try {
      String? fcmToken;
      if (kIsWeb || !Platform.isWindows) {
        fcmToken = _fcmService.token;
      }

      final deviceId = await _deviceService.getDeviceId();

      final response = await _authService.login(email, senha, deviceId: deviceId, deviceToken: fcmToken);
      if (response['success'] == true) {
        debugPrint('✅ [AUTH] Login realizado com sucesso');
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

        await _fcmService.sendTokenToBackend();
        await getIt<StoreCubit>().updateStores(authData.lojas);

        emit(AuthAuthenticated(lojista, token));
      } else {
        debugPrint('❌ [AUTH] Falha no login: ${response['message']}');
        emit(AuthError(response['message'] ?? 'Email ou senha inválidos'));
      }
    } catch (e) {
      debugPrint('❌ [AUTH] Exceção no login: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    debugPrint('🔐 [AUTH] Realizando logout...');
    try {
      await _fcmService.removeTokenFromBackend();
      await _authService.logout();
    } catch (_) {}
    
    await _deviceService.clearDeviceId();
    await _storageService.clearAll();
    await _tokenService.clear();
    await getIt<StoreCubit>().clear();
    debugPrint('✅ [AUTH] Logout concluído');
    emit(AuthUnauthenticated());
  }
}
