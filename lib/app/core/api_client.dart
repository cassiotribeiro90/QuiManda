import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../services/token_service.dart';
import 'interceptors/refresh_interceptor.dart';
import 'constants.dart';
import 'storage/store_storage.dart';
import 'navigation/navigation_service.dart';

class ApiClient {
  static GlobalKey<NavigatorState> get navigatorKey => NavigationService.navigatorKey;
  
  late final Dio dio;
  final TokenService _tokenService;
  final StoreStorage _storeStorage;

  ApiClient(this._tokenService, this._storeStorage) {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 🔥 ADICIONA O HEADER DE AUTENTICAÇÃO
        final token = await _tokenService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // 🔥 ADICIONA O HEADER X-Store-Id (LENDO DIRETAMENTE DO STORAGE)
        final storeId = _storeStorage.getSelectedStoreId();
        if (storeId != null) {
          options.headers['X-Store-Id'] = storeId.toString();
        }

        // LOG PARA DEPURAÇÃO
        if (kDebugMode) {
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          debugPrint('📤 [ApiClient] ENVIANDO REQUISIÇÃO');
          debugPrint('📤 URL: ${options.baseUrl}${options.path}');
          debugPrint('📤 Método: ${options.method}');
          debugPrint('📤 Headers: ${options.headers}');
          if (options.data != null) {
            debugPrint('📤 Body: ${options.data}');
          }
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 🔥 LOG DETALHADO DA RESPOSTA
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('📥 [ApiClient] RESPOSTA RECEBIDA');
        debugPrint('📥 URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}');
        debugPrint('📥 Status: ${response.statusCode}');
        if (response.data != null) {
          debugPrint('📥 Body: ${response.data}');
        }
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        return handler.next(response);
      },
      onError: (e, handler) {
        // 🔥 LOG DETALHADO DO ERRO
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('❌ [ApiClient] ERRO NA REQUISIÇÃO');
        debugPrint('❌ URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}');
        debugPrint('❌ Método: ${e.requestOptions.method}');
        debugPrint('❌ Tipo: ${e.type}');
        debugPrint('❌ Mensagem: ${e.message}');
        if (e.response != null) {
          debugPrint('❌ Status Code: ${e.response?.statusCode}');
          debugPrint('❌ Response Body: ${e.response?.data}');
        }
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        return handler.next(e);
      },
    ));

    // Adiciona o RefreshInterceptor para lidar com 401
    dio.interceptors.add(RefreshInterceptor(
      dio: dio,
      tokenService: _tokenService,
      navigatorKey: navigatorKey,
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) {
    return dio.get(path, queryParameters: queryParams);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParams}) {
    return dio.post(path, data: data, queryParameters: queryParams);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParams}) {
    return dio.put(path, data: data, queryParameters: queryParams);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParams}) {
    return dio.delete(path, data: data, queryParameters: queryParams);
  }
}
