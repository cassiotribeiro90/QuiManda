import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/token_service.dart';
import '../storage/store_storage.dart';
import '../../modules/auth/service/auth_service.dart';

class RefreshInterceptor extends Interceptor {
  final Dio dio;
  final TokenService tokenService;
  final GlobalKey<NavigatorState> navigatorKey;
  final StoreStorage storeStorage;
  late final AuthService _authService;
  bool _isRefreshing = false; // 🔥 Evita múltiplos refresh simultâneos
  final List<Map<String, dynamic>> _pendingRequests = []; // 🔥 Fila de requisições pendentes

  RefreshInterceptor({
    required this.dio,
    required this.tokenService,
    required this.navigatorKey,
    required this.storeStorage,
  }) {
    // 🔥 Cria o AuthService com o ApiClient sem interceptores para evitar loop
    _authService = AuthService(tokenService, storeStorage);
  }

  // 🔥 ROTAS QUE NÃO DEVEM TENTAR REFRESH
  static const List<String> _authRoutes = [
    '/auth-lojista/login',
    '/auth-lojista/refresh-token',
    '/auth-lojista/logout',
    '/auth-lojista/device-token',
    '/auth-lojista/phone',
    '/auth-lojista/verify-otp',
    '/auth-lojista/create',
  ];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 🔥 Se não for 401, repassa o erro
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final requestPath = err.requestOptions.path;
    
    // 🔥 VERIFICA SE É ROTA DE AUTENTICAÇÃO
    final isAuthRoute = _authRoutes.any((route) => requestPath.contains(route));

    // 🔥 Se for rota de autenticação, NÃO TENTA REFRESH
    if (isAuthRoute) {
      debugPrint('⛔ [API] Rota de autenticação - NÃO faz refresh: $requestPath');
      handler.next(err);
      return;
    }

    // 🔥 Se já está em processo de refresh, coloca na fila
    if (_isRefreshing) {
      debugPrint('⏳ [API] Refresh em andamento, enfileirando requisição: $requestPath');
      _pendingRequests.add({'err': err, 'handler': handler});
      return;
    }

    debugPrint('⚠️ [API] Token expirado (401) em $requestPath. Iniciando refresh...');
    // 🔥 Tenta refresh com timeout de 15s para não travar a aplicação
    try {
      await _handleRefresh(err, handler).timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('❌ [API] Timeout ou erro fatal no processo de refresh: $e');
      _isRefreshing = false;
      await _forceLogout();
      if (!handler.isCompleted) {
        handler.next(err);
      }
    }
  }

  Future<void> _handleRefresh(DioException err, ErrorInterceptorHandler handler) async {
    _isRefreshing = true;
    debugPrint('🔄 [API] Refresh Interceptor: Buscando refresh token...');

    try {
      final refreshToken = await tokenService.getRefreshToken();
      debugPrint('🔑 [API] Refresh token: ${refreshToken != null ? 'encontrado' : 'NÃO ENCONTRADO'}');
      
      if (refreshToken == null) {
        debugPrint('❌ [API] Abortando refresh: token nulo');
        await _forceLogout();
        handler.next(err);
        return;
      }

      debugPrint('📤 [API] Chamando endpoint de refresh...');
      // 🔥 O refresh agora usa logs internos para sabermos se o backend respondeu
      final response = await _authService.refreshToken(refreshToken);

      if (response['success'] == true) {
        final data = response['data'] ?? {};
        final newAccessToken = data['access_token'] ?? data['token'];
        final newRefreshToken = data['refresh_token'];

        if (newAccessToken != null) {
          debugPrint('✅ [API] Novo Access Token recebido: ${newAccessToken.substring(0, 10)}...');
          
          // 🔥 Salva os novos tokens
          await tokenService.saveTokens(newAccessToken, newRefreshToken ?? refreshToken);
          debugPrint('✅ [API] Tokens persistidos com sucesso');

          // 🔥 Reexecuta a requisição original
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newAccessToken';

          debugPrint('🔁 [API] Reexecutando requisição original: ${options.path}');
          final retryResponse = await dio.fetch(options);
          handler.resolve(retryResponse);

          // 🔥 Reexecuta requisições pendentes
          await _processPendingRequests(newAccessToken);
          return;
        } else {
          debugPrint('❌ [API] Backend retornou sucesso mas sem token');
        }
      } else {
        debugPrint('❌ [API] Backend recusou o refresh: ${response['message']}');
      }
    } catch (e) {
      debugPrint('❌ [API] Exceção durante o fluxo de refresh: $e');
    } finally {
      _isRefreshing = false;
    }

    debugPrint('❌ [API] Refresh falhou completamente - forçando logout');
    await _forceLogout();
    handler.next(err);
  }

  // 🔥 Processa requisições que estavam esperando o refresh
  Future<void> _processPendingRequests(String newToken) async {
    if (_pendingRequests.isEmpty) return;

    debugPrint('🔄 [API] Processando ${_pendingRequests.length} requisições pendentes...');

    for (final request in List.from(_pendingRequests)) {
      final DioException err = request['err'];
      final ErrorInterceptorHandler handler = request['handler'];
      
      try {
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newToken';
        
        final response = await dio.fetch(options);
        handler.resolve(response);
      } catch (e) {
        debugPrint('⚠️ [API] Erro ao reexecutar requisição pendente: $e');
        handler.reject(e is DioException ? e : DioException(requestOptions: err.requestOptions, error: e));
      }
    }
    _pendingRequests.clear();
  }

  Future<void> _forceLogout() async {
    // Cancela todas as requisições pendentes com erro
    for (final request in _pendingRequests) {
      final ErrorInterceptorHandler handler = request['handler'];
      final DioException err = request['err'];
      handler.reject(err);
    }
    _pendingRequests.clear();

    try {
      // 🔥 Tenta remover o device token (ignora erros)
      try {
        final storeId = storeStorage.getSelectedStoreId();
        final token = await tokenService.getAccessToken();
        if (token != null && storeId != null) {
          await dio.delete(
            '/auth-lojista/device-token',
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'X-Store-Id': storeId.toString(),
              },
            ),
          );
          debugPrint('✅ [API] Device token removido');
        }
      } catch (e) {
        debugPrint('⚠️ [API] Erro ao remover device token: $e');
      }

      // 🔥 Tenta logout (ignora erros)
      try {
        final storeId = storeStorage.getSelectedStoreId();
        final token = await tokenService.getAccessToken();
        if (token != null && storeId != null) {
          await dio.post(
            '/auth-lojista/logout',
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'X-Store-Id': storeId.toString(),
              },
            ),
          );
          debugPrint('✅ [API] Logout realizado');
        }
      } catch (e) {
        debugPrint('⚠️ [API] Erro no logout: $e');
      }
    } catch (e) {
      debugPrint('⚠️ [API] Erro no forceLogout: $e');
    } finally {
      // 🔥 LIMPA TODOS OS TOKENS LOCAIS
      await tokenService.clear();
      await storeStorage.clear();
      _redirectToLogin();
    }
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
