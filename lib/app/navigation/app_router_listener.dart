import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../modules/auth/cubit/auth_cubit.dart';
import '../modules/auth/cubit/auth_state.dart';
import '../routes/app_router.dart';
import 'navigation_cubit.dart';
import 'navigation_state.dart';

/// Widget que escuta mudanças na navegação e autenticação e executa as ações
class AppRouterListener extends StatelessWidget {
  final Widget child;

  const AppRouterListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<NavigationCubit, NavigationState>(
          listener: (context, state) {
            debugPrint('👂 [LISTENER] Estado de navegação recebido: ${state.type}');
            
            // 🔥 Usa o contexto da chave global para garantir acesso ao GoRouter
            final routerContext = rootNavigatorKey.currentContext;
            
            if (routerContext == null) {
              debugPrint('⚠️ [LISTENER] Router Context ainda nulo - ignorando navegação');
              return;
            }

            if (state.type == NavigationType.push) {
              debugPrint('📤 [LISTENER] Executando push para: ${state.location}');
              routerContext.push(state.location!, extra: state.extra);
            } else if (state.type == NavigationType.go) {
              debugPrint('🚀 [LISTENER] Executando go para: ${state.location}');
              routerContext.go(state.location!, extra: state.extra);
            } else if (state.type == NavigationType.pop) {
              debugPrint('⬅️ [LISTENER] Executando pop');
              routerContext.pop();
            }
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            debugPrint('🔐 [LISTENER] Estado de autenticação mudou: ${state.runtimeType}');
            final nav = context.read<NavigationCubit>();
            
            if (state is AuthAuthenticated) {
              debugPrint('✅ [LISTENER] Usuário autenticado');
              
              // Tenta obter a localização atual para evitar redirecionamento forçado
              String? currentLocation;
              final routerContext = rootNavigatorKey.currentContext;
              if (routerContext != null) {
                try {
                  currentLocation = GoRouter.of(routerContext).routeInformationProvider.value.uri.toString();
                  debugPrint('📍 [LISTENER] Localização atual detectada: $currentLocation');
                } catch (e) {
                  debugPrint('⚠️ [LISTENER] Erro ao obter localização: $e');
                }
              }

              nav.goToDashboardIfNeeded(currentLocation ?? '/');
            } else if (state is AuthUnauthenticated) {
              debugPrint('❌ [LISTENER] Usuário não autenticado');
              
              String? currentLocation;
              final routerContext = rootNavigatorKey.currentContext;
              if (routerContext != null) {
                try {
                  currentLocation = GoRouter.of(routerContext).routeInformationProvider.value.uri.toString();
                } catch (_) {}
              }
              
              // Se está na Splash (/), Onboarding ou qualquer rota protegida, redireciona
              final publicRoutes = ['/phone-input', '/otp-verify', '/onboarding'];
              
              if (currentLocation == '/' || currentLocation == '/splash') {
                debugPrint('🚀 [LISTENER] Saindo da Splash -> Indo para Onboarding');
                nav.goToOnboarding();
              } else if (currentLocation != null && !publicRoutes.any((route) => currentLocation!.startsWith(route))) {
                 debugPrint('🔐 [LISTENER] Rota protegida detectada sem auth -> Indo para Login');
                 nav.goToLogin();
              } else {
                 debugPrint('✅ [LISTENER] Mantendo em rota pública: $currentLocation');
              }
            }
          },
        ),
      ],
      child: child,
    );
  }
}
