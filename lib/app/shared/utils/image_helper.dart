import '../../core/constants/app_constants.dart';

class ImageHelper {
  /// 🔥 Converte caminho relativo para URL completa
  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '${AppConstants.imageBaseUrl}/$cleanPath';
  }

  /// 🔥 Extrai caminho relativo de uma URL completa
  static String? extractPath(String? url) {
    if (url == null || url.isEmpty) return null;

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return url.startsWith('/') ? url.substring(1) : url;
    }

    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      return path.startsWith('/') ? path.substring(1) : path;
    } catch (e) {
      return url;
    }
  }

  static String get imageBaseUrl => AppConstants.imageBaseUrl;
}
