import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // 🔥 LOG DETALHADO DA REQUISIÇÃO
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('📤 [ApiClient] ENVIANDO REQUISIÇÃO');
        debugPrint('📤 URL: ${options.baseUrl}${options.path}');
        debugPrint('📤 Método: ${options.method}');
        debugPrint('📤 Headers: ${options.headers}');
        if (options.data != null) {
          debugPrint('📤 Body: ${options.data}');
        }
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

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

        // Handle global errors like 401 Unauthorized
        if (e.response?.statusCode == 401) {
          // Could trigger logout here
        }
        return handler.next(e);
      },
    ));
  }
}
