import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConstants {
  // ================================================================
  // 🔥 URL BASE DA API (SEM /api)
  // ================================================================

  static String get apiBaseUrl {
    const String envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:8001'; // <-- SEM /api
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8001'; // <-- SEM /api
    }

    return 'http://localhost:8001'; // <-- SEM /api
  }

  // 🔥 URL BASE PARA IMAGENS (MESMA COISA, SEM /api)
  static String get imageBaseUrl {
    return apiBaseUrl; // <-- MESMA COISA
  }

  // ================================================================
  // 🔥 ENDPOINTS (COM /api)
  // ================================================================

  static const String uploadEndpoint = '/api/upload'; // <-- COM /api

  // ================================================================
  // 🔥 PASTAS DE UPLOAD
  // ================================================================

  static const String folderProducts = 'produtos';
  static const String folderCategories = 'categorias';
  static const String folderProfile = 'perfil';
  static const String folderReviews = 'avaliacoes';
  static const String folderBanners = 'banners';
  static const String folderStores = 'lojas';

  // ================================================================
  // 🔥 CONFIGURAÇÕES DE UPLOAD
  // ================================================================

  static const int maxImageSize = 5 * 1024 * 1024;
  static const int imageQuality = 75;
  static const int imageMaxWidth = 1200;
  static const int imageMaxHeight = 1200;
}