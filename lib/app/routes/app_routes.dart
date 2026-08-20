import 'package:flutter/material.dart';
import '../modules/auth/views/splash_page.dart';
import '../modules/auth/views/phone_input_page.dart';
import '../modules/auth/views/otp_verification_page.dart';
import '../modules/home/views/home_view.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/cardapio/views/cardapio_page.dart';
import '../modules/cardapio/views/formulario_produto_page.dart';
import '../modules/configuracoes/views/configuracoes_loja_page.dart';

import '../modules/store/views/store_selection_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String phoneInput = '/phone-input';
  static const String otpVerify = '/otp-verify';
  static const String dashboard = '/dashboard';
  static const String cardapio = '/cardapio';
  static const String formularioProduto = '/formulario-produto';
  static const String configuracoes = '/configuracoes';
  static const String storeSelection = '/store-selection';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashPage(),
    onboarding: (context) => const OnboardingView(),
    phoneInput: (context) => const PhoneInputPage(),
    otpVerify: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return OtpVerificationPage(telefone: args['telefone'] as String);
    },
    dashboard: (context) => const HomeView(),
    cardapio: (context) => const CardapioPage(),
    formularioProduto: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args['produto'] != null) {
        return FormularioProdutoPage(produto: args['produto']);
      }
      return const FormularioProdutoPage();
    },
    configuracoes: (context) => const ConfiguracoesLojaPage(),
    storeSelection: (context) => const StoreSelectionPage(),
  };
}
