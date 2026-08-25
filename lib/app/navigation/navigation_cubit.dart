import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_state.dart';

/// Cubit responsável por controlar a navegação do app
class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState.initial()) {
    debugPrint('🚀 [NAVIGATION] Cubit inicializado');
  }

  // ============= MÉTODOS PÚBLICOS =============
  
  void push(String location, {Object? extra}) {
    debugPrint('📤 [NAVIGATION] Push para: $location');
    emit(NavigationState.push(location, extra: extra));
  }

  void go(String location, {Object? extra}) {
    debugPrint('🚀 [NAVIGATION] Go para: $location (substituindo pilha)');
    emit(NavigationState.go(location, extra: extra));
  }

  void pop() {
    debugPrint('⬅️ [NAVIGATION] Pop (voltar)');
    emit(NavigationState.pop());
  }

  // ============= MÉTODOS ESPECÍFICOS (quiManda) =============
  
  // Autenticação e Onboarding
  void goToPhoneInput() => go('/phone-input');
  void goToLogin() {
    debugPrint('🔐 [NAVIGATION] Redirecionando para Login');
    go('/phone-input');
  }
  void goToOtpVerify(String telefone) => go('/otp-verify', extra: {'telefone': telefone});
  void goToOnboarding() {
    debugPrint('📖 [NAVIGATION] Redirecionando para Onboarding');
    go('/onboarding');
  }
  void goToStoreSelection() => go('/store-selection');
  
  // Shell Modules (Usa go para atualizar a URL e refletir no SideMenu)
  void goToDashboard() => go('/dashboard');
  void goToPedidos() => go('/pedidos');
  void goToCardapio() => go('/cardapio');
  void goToConfiguracoes() => go('/configuracoes');

  // Detalhes e Formulários
  void goToFormularioProduto({Object? produto}) => push('/formulario-produto', extra: {'produto': produto});

  // ============= MÉTODOS DE APOIO (Redirecionamento Inteligente) =============

  /// Verifica se é uma rota protegida
  bool isProtectedRoute(String location) {
    final protected = [
      '/dashboard',
      '/pedidos',
      '/cardapio',
      '/configuracoes',
      '/formulario-produto',
      '/store-selection',
    ];
    return protected.any((route) => location.startsWith(route));
  }

  /// Navega para Dashboard apenas se necessário (não estiver em rota protegida)
  void goToDashboardIfNeeded(String currentLocation) {
    if (isProtectedRoute(currentLocation)) {
      debugPrint('✅ [NAVIGATION] Mantendo rota protegida atual: $currentLocation');
      return;
    }
    debugPrint('🚀 [NAVIGATION] Redirecionando para Dashboard');
    goToDashboard();
  }
}
