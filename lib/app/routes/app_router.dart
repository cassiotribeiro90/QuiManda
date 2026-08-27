import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/splash_screen.dart';
import '../modules/auth/views/phone_input_page.dart';
import '../modules/auth/views/otp_verification_page.dart';
import '../modules/home/views/home_view.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/cardapio/views/cardapio_page.dart';
import '../modules/cardapio/views/formulario_produto_page.dart';
import '../modules/configuracoes/views/configuracoes_loja_page.dart';
import '../modules/store/views/store_selection_page.dart';
import '../modules/pedidos/views/pedidos_list_page.dart';
import '../modules/dashboard/views/dashboard_screen.dart';
import '../core/navigation/navigation_observer.dart';

// 🔑 Chaves de navegação
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/pedidos', // 🔥 TELA INICIAL = PEDIDOS
  debugLogDiagnostics: true,
  observers: [NavigationObserver()],
  routes: [
    // ============= ROTAS PÚBLICAS =============
    GoRoute(
      path: '/',
      name: 'splash',
      redirect: (context, state) => '/pedidos', // 🔥 Redireciona raiz para pedidos
      builder: (context, state) {
        debugPrint('🔄 [ROUTER] Abrindo Splash');
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) {
        debugPrint('📱 [ROUTER] Abrindo Onboarding');
        return const OnboardingView();
      },
    ),
    GoRoute(
      path: '/phone-input',
      name: 'phone-input',
      builder: (context, state) {
        debugPrint('🔐 [ROUTER] Abrindo Login (Phone Input)');
        return const PhoneInputPage();
      },
    ),
    GoRoute(
      path: '/otp-verify',
      name: 'otp-verify',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        final telefone = args?['telefone'] as String? ?? '';
        debugPrint('🔐 [ROUTER] Abrindo Verificação OTP para: $telefone');
        return OtpVerificationPage(telefone: telefone);
      },
    ),

    // ============= ROTAS PROTEGIDAS (FORA DA SHELL) =============
    GoRoute(
      path: '/store-selection',
      name: 'store-selection',
      builder: (context, state) {
        debugPrint('🏪 [ROUTER] Abrindo Seleção de Loja');
        return const StoreSelectionPage();
      },
    ),

    // ============= ROTAS PROTEGIDAS (DENTRO DA SHELL) =============
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        debugPrint('🏠 [ROUTER] Construindo Shell (HomeView)');
        return HomeView(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) {
            debugPrint('📊 [ROUTER] Abrindo Dashboard');
            return const DashboardScreen();
          },
        ),
        GoRoute(
          path: '/pedidos',
          name: 'pedidos',
          builder: (context, state) {
            debugPrint('📋 [ROUTER] Abrindo Pedidos');
            return const PedidosListPage();
          },
        ),
        GoRoute(
          path: '/cardapio',
          name: 'cardapio',
          builder: (context, state) {
            debugPrint('🍽️ [ROUTER] Abrindo Cardápio');
            return const CardapioPage();
          },
        ),
        GoRoute(
          path: '/configuracoes',
          name: 'configuracoes',
          builder: (context, state) {
            debugPrint('⚙️ [ROUTER] Abrindo Configurações');
            return const ConfiguracoesLojaPage();
          },
        ),
      ],
    ),

    // ============= ROTAS DE FORMULÁRIOS (FULL SCREEN) =============
    GoRoute(
      path: '/formulario-produto',
      name: 'formulario-produto',
      parentNavigatorKey: rootNavigatorKey, // Abre por cima da Shell
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        final produto = args?['produto'];
        debugPrint('📦 [ROUTER] Abrindo Formulário de Produto. Edição: ${produto != null}');
        return FormularioProdutoPage(produto: produto);
      },
    ),
  ],
);
