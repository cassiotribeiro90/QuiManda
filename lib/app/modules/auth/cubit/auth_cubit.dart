import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
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
import '../../../core/storage/store_storage.dart';
import '../../../core/api_client.dart';
import 'package:go_router/go_router.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final TokenService _tokenService;
  final StorageService _storageService;
  final FcmService _fcmService;
  final DeviceService _deviceService;
  final StoreStorage _storeStorage;
  
  AuthCubit({
    required AuthService authService,
    required TokenService tokenService,
    required StorageService storageService,
    required FcmService fcmService,
    required DeviceService deviceService,
    required StoreStorage storeStorage,
  }) : _authService = authService,
       _tokenService = tokenService,
       _storageService = storageService,
       _fcmService = fcmService,
       _deviceService = deviceService,
       _storeStorage = storeStorage,
       super(AuthInitial()) {
    debugPrint('🔐 [AUTH] Cubit inicializado');
  }

  // 🔥 1. VERIFICAR STATUS DE AUTENTICAÇÃO
  Future<void> checkAuthStatus() async {
    debugPrint('🚀 [AUTH] Verificando status...');
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final hasToken = await _tokenService.hasValidToken();
      
      if (hasToken) {
        final lojistaData = _tokenService.getLojistaData();
        if (lojistaData != null) {
          final lojista = LojistaModel.fromJson(lojistaData);
          debugPrint('✅ [AUTH] Usuário autenticado: ${lojista.nome}');
          await getIt<StoreCubit>().loadStores();
          emit(AuthAuthenticated(lojista, (await _tokenService.getAccessToken())!));
        } else {
          debugPrint('⚠️ [AUTH] Token existe mas dados do lojista não. Validando no servidor...');
          await checkAuth();
        }
      } else {
        debugPrint('❌ [AUTH] Sem tokens ativos');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('❌ [AUTH] Erro na verificação: $e');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> checkAuth() async {
    debugPrint('🚀 [AUTH] Validando token com o servidor...');
    final token = await _tokenService.getAccessToken();
    
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

  // 🔥 2. LOGIN / VERIFICAÇÃO OTP
  Future<void> verifyOtp(String telefone, String codigo) async {
    debugPrint('🔐 [AUTH] Tentando login para: $telefone');
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
        debugPrint('✅ [AUTH] OTP verificado. Resposta completa: ${jsonEncode(response)}');
        final authData = AuthResponse.fromJson(response);
        
        final accessToken = authData.accessToken;
        final refreshToken = authData.refreshToken;
        
        if (accessToken == null || refreshToken == null) {
          debugPrint('❌ [AUTH] Tokens não encontrados na resposta. access=$accessToken, refresh=$refreshToken');
          emit(AuthError('Erro ao obter tokens de autenticação'));
          return;
        }

        debugPrint('📦 [AUTH] Tokens recebidos:');
        debugPrint('   Access Token: ${accessToken.substring(0, 10)}...');
        debugPrint('   Refresh Token: ${refreshToken.substring(0, 10)}...');

        // 🔥 SALVA OS TOKENS
        await _tokenService.saveTokens(
          accessToken, 
          refreshToken,
          tokenType: authData.tokenType,
          expiresIn: authData.expiresIn,
        );
        
        await _tokenService.saveLojista(response['data']['lojista']);

        debugPrint('🎯 [AUTH] Enviando token para o backend...');
        await _fcmService.sendTokenToBackend();
        
        debugPrint('🏪 [AUTH] Atualizando lojas...');
        await getIt<StoreCubit>().updateStores(authData.lojas);

        debugPrint('🧭 [AUTH] Login concluído com sucesso. Emitindo AuthAuthenticated...');
        emit(AuthAuthenticated(authData.lojista!, accessToken));
      } else {
        debugPrint('❌ [AUTH] Código OTP inválido: ${response['message']}');
        emit(AuthError(response['message'] ?? 'Código inválido'));
      }
    } catch (e, stack) {
      debugPrint('❌ [AUTH] Exceção ao verificar OTP: $e');
      debugPrint(stack.toString());
      emit(AuthError(e.toString()));
    }
  }

  // 🔥 3. REFRESH TOKEN
  Future<bool> refreshToken() async {
    debugPrint('🔄 [AUTH] Tentando refresh token...');
    try {
      // Pega o refresh token salvo
      final refreshToken = await _tokenService.getRefreshToken();
      
      if (refreshToken == null) {
        debugPrint('❌ [AUTH] Refresh token não disponível no storage');
        return false;
      }
      
      debugPrint('📤 [AUTH] Enviando refresh token: ${refreshToken.substring(0, 10)}...');
      
      final response = await _authService.refreshToken(refreshToken);
      
      if (response['success'] == true) {
        final data = response['data'] ?? {};
        final newAccessToken = data['access_token'] as String?;
        
        if (newAccessToken == null) {
          debugPrint('❌ [AUTH] Novo access token não encontrado na resposta');
          return false;
        }
        
        // 🔥 SALVA APENAS O NOVO ACCESS TOKEN
        // O refresh token geralmente permanece o mesmo no seu backend PHP
        await _tokenService.saveAccessToken(newAccessToken);
        
        debugPrint('✅ [AUTH] Refresh token bem-sucedido');
        return true;
      }
      
      debugPrint('❌ [AUTH] Falha no refresh (Backend): ${response['message']}');
      return false;
    } catch (e) {
      debugPrint('❌ [AUTH] Erro no refresh: $e');
      return false;
    }
  }

  // 🔥 4. LOGOUT
  Future<void> logout() async {
    debugPrint('🔐 [AUTH] Realizando logout...');
    try {
      await _fcmService.removeTokenFromBackend();
      await _authService.logout();
    } catch (_) {}
    
    await _deviceService.clearDeviceId();
    await _tokenService.clear();
    await _storageService.clearAll();
    await _storeStorage.clear();
    await getIt<StoreCubit>().clear();
    
    debugPrint('✅ [AUTH] Logout realizado com sucesso');
    emit(AuthUnauthenticated());
    _navigateToLogin();
  }

  void _navigateToLogin() {
    final context = ApiClient.navigatorKey.currentContext;
    if (context != null) {
      debugPrint('🔐 [AUTH] Redirecionando para login');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/phone-input');
      });
    }
  }

  // Métodos legados ou auxiliares mantidos para compatibilidade
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

        if (refreshToken != null) {
          await _tokenService.saveTokens(token, refreshToken);
        } else {
          await _tokenService.saveAccessToken(token);
        }
        
        await _tokenService.saveLojista(response['data']['lojista']);
        await _fcmService.sendTokenToBackend();
        await getIt<StoreCubit>().updateStores(authData.lojas);
        emit(AuthAuthenticated(authData.lojista!, token));
      } else {
        debugPrint('❌ [AUTH] Falha no login: ${response['message']}');
        emit(AuthError(response['message'] ?? 'Email ou senha inválidos'));
      }
    } catch (e) {
      debugPrint('❌ [AUTH] Exceção no login: $e');
      emit(AuthError(e.toString()));
    }
  }
}
