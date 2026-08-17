import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
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
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Se o erro for 401 (Não autorizado) e não for na rota de login ou refresh
    if (err.response?.statusCode == 401 && 
        !err.requestOptions.path.contains('auth-lojista/login') &&
        !err.requestOptions.path.contains('auth-lojista/refresh-token')) {
      
      final refreshToken = tokenService.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Tenta renovar o token
          final success = await tokenService.refreshTokens(dio);

          if (success) {
            // Repete a requisição original com o novo token
            final newToken = tokenService.getAccessToken();
            
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';

            final response = await dio.fetch(options);
            return handler.resolve(response);
          }
        } catch (e) {
          debugPrint('❌ [RefreshInterceptor] Erro ao tentar renovar token: $e');
        }
      }

      // Se falhar o refresh ou não houver refresh token, desloga e manda para o login
      await tokenService.clear();
      _redirectToLogin();
    }

    return handler.next(err);
  }

  void _redirectToLogin() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.phoneInput, (route) => false);
      });
    }
  }
}
