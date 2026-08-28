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
            debugPrint('👂 [LISTENER] Evento de navegação: ${state.type} para ${state.location}');
            
            final routerContext = rootNavigatorKey.currentContext;
            
            if (routerContext == null) {
              debugPrint('⚠️ [LISTENER] rootNavigatorKey.currentContext é NULO. Agendando para o próximo frame...');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final retryContext = rootNavigatorKey.currentContext;
                if (retryContext != null) {
                  debugPrint('🔄 [LISTENER] Tentando novamente navegação no postFrame para ${state.location}');
                  _executeNavigation(retryContext, state);
                } else {
                  debugPrint('❌ [LISTENER] Falha crítica: Contexto continua nulo após postFrame');
                }
              });
              return;
            }

            _executeNavigation(routerContext, state);
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            debugPrint('🔐 [LISTENER] AuthState: ${state.runtimeType}');
            final nav = context.read<NavigationCubit>();
            
            if (state is AuthAuthenticated) {
              debugPrint('✅ [LISTENER] Autenticado! Verificando redirecionamento...');
              
              String? currentLocation;
              final routerContext = rootNavigatorKey.currentContext;
              if (routerContext != null) {
                try {
                  final uri = GoRouter.of(routerContext).routeInformationProvider.value.uri;
                  currentLocation = uri.toString();
                  debugPrint('📍 [LISTENER] URI Atual: $currentLocation');
                } catch (e) {
                  debugPrint('⚠️ [LISTENER] Não foi possível ler URI: $e');
                }
              }

              // Se estiver na tela de login ou splash, vai para o dashboard
              if (currentLocation == null || 
                  currentLocation == '/' || 
                  currentLocation.contains('login') || 
                  currentLocation.contains('otp') ||
                  currentLocation.contains('phone')) {
                debugPrint('🚀 [LISTENER] Redirecionando para Dashboard');
                nav.goToDashboard();
              } else {
                debugPrint('✅ [LISTENER] Já está em uma rota válida: $currentLocation');
              }
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

  void _executeNavigation(BuildContext context, NavigationState state) {
    try {
      if (state.type == NavigationType.push) {
        debugPrint('📤 [LISTENER] Executando push para: ${state.location}');
        context.push(state.location!, extra: state.extra);
      } else if (state.type == NavigationType.go) {
        debugPrint('🚀 [LISTENER] Executando go para: ${state.location}');
        context.go(state.location!, extra: state.extra);
      } else if (state.type == NavigationType.pop) {
        debugPrint('⬅️ [LISTENER] Executando pop');
        context.pop();
      }
    } catch (e, stack) {
      debugPrint('❌ [LISTENER] Erro ao executar navegação GoRouter: $e');
      debugPrint(stack.toString());
    }
  }
}
