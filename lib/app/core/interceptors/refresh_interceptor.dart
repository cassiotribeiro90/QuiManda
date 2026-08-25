import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/token_service.dart';
import '../../modules/auth/cubit/auth_cubit.dart';
import '../../di/dependencies.dart';

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
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Se o erro for 401 (Não autorizado) e não for na rota de login ou refresh
    if (err.response?.statusCode == 401) {
      final requestPath = err.requestOptions.path;
      debugPrint('⚠️ [API] Token expirado (401) em $requestPath');

      // ⚠️ NÃO tenta refresh em rotas de autenticação
      if (requestPath.contains('auth-lojista/login') ||
          requestPath.contains('auth-lojista/refresh-token') ||
          requestPath.contains('auth-lojista/verify-otp') ||
          requestPath.contains('auth-lojista/phone')) {
        debugPrint('⛔ [API] Rota de autenticação - não faz refresh');
        return handler.next(err);
      }

      // 🔥 TENTA REFRESH VIA AUTH_CUBIT
      try {
        final authCubit = getIt<AuthCubit>();
        final success = await authCubit.refreshToken();

        if (success) {
          debugPrint('✅ [API] Refresh bem-sucedido, reexecutando requisição...');
          
          final newToken = await tokenService.getAccessToken();
          if (newToken != null) {
            // Atualiza o header da requisição original
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';

            // Reexecuta a requisição
            final response = await dio.fetch(options);
            return handler.resolve(response);
          }
        }
      } catch (e) {
        debugPrint('❌ [API] Erro ao tentar renovar token: $e');
      }

      debugPrint('❌ [API] Falha no refresh - redirecionando para login');
      // Se falhar o refresh, desloga via AuthCubit
      try {
        await getIt<AuthCubit>().logout();
      } catch (_) {
        await tokenService.clear();
      }
      _redirectToLogin();
      return handler.next(err);
    }

    debugPrint('❌ [API] Erro: ${err.message} (${err.response?.statusCode})');
    return handler.next(err);
  }

  void _redirectToLogin() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      debugPrint('🔐 [AUTH] Redirecionando para login via GoRouter');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Usa go para limpar a pilha
        context.go('/phone-input');
      });
    }
  }
}
