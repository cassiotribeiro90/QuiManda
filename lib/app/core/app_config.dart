import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    // 1. Variável de ambiente via --dart-define=API_URL=...
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl;
    
    // 2. Produção vs Desenvolvimento
    const isProd = bool.fromEnvironment('PROD');
    if (isProd) return 'https://api.quimanda.com.br';

    // Web
    if (kIsWeb) return 'http://localhost:8001';
    
    // Android Emulator
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8001';
    }
    
    // Outros (iOS Simulator, Desktop, etc)
    return 'http://localhost:8001';
  }
  static const String dashboard = '/api/lojista/dashboard';
}
