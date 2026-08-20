import 'lojista_model.dart';
import 'loja_model.dart';

class AuthResponse {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? tokenType;
  final LojistaModel? lojista;
  final List<LojaModel> lojas;

  AuthResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.tokenType,
    this.lojista,
    this.lojas = const [],
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
      expiresIn: data['expires_in'],
      tokenType: data['token_type'],
      lojista: data['lojista'] != null 
          ? LojistaModel.fromJson(data['lojista']) 
          : null,
      lojas: (data['lojas'] as List<dynamic>?)
          ?.map((e) => LojaModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  factory AuthResponse.fromPhoneResponse(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      lojista: null,
    );
  }

  bool get isAuthenticated => success && accessToken != null;
}
