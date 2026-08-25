import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/token_service.dart';


class RefreshInterceptor extends Interceptor {
  final Dio dio;
  final TokenService tokenService;
  final GlobalKey<NavigatorState> navigatorKey;

  RefreshInterceptor({
    required this.dio,
    required this.tokenService,
    required this.navigatorKey,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('🌐 [API] Requisição: ${options.method} ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('✅ [API] Resposta: ${response.statusCode} ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Se o erro for 401 (Não autorizado) e não for na rota de login ou refresh
    if (err.response?.statusCode == 401 && 
        !err.requestOptions.path.contains('auth-lojista/login') &&
        !err.requestOptions.path.contains('auth-lojista/refresh-token')) {
      
      debugPrint('⚠️ [API] Token expirado (401) em ${err.requestOptions.path} - Tentando refresh...');
      final refreshToken = tokenService.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Tenta renovar o token
          final success = await tokenService.refreshTokens(dio);

          if (success) {
            debugPrint('🔄 [API] Refresh token realizado com sucesso. Repetindo requisição...');
            // Repete a requisição original com o novo token
            final newToken = tokenService.getAccessToken();
            
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';

            final response = await dio.fetch(options);
            return handler.resolve(response);
          }
        } catch (e) {
          debugPrint('❌ [API] Erro ao tentar renovar token: $e');
        }
      }

      debugPrint('❌ [API] Falha no refresh ou token ausente. Redirecionando para login.');
      // Se falhar o refresh ou não houver refresh token, desloga e manda para o login
      await tokenService.clear();
      _redirectToLogin();
    }

    debugPrint('❌ [API] Erro: ${err.message} (${err.response?.statusCode})');
    return handler.next(err);
  }

  void _redirectToLogin() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      debugPrint('🔐 [AUTH] Redirecionando para login via GoRouter');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/phone-input');
      });
    }
  }
}
