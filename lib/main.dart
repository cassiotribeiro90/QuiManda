import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/core/app_theme.dart';
import 'app/di/dependencies.dart';
import 'app/modules/auth/cubit/auth_cubit.dart';
import 'app/modules/auth/cubit/auth_state.dart';
import 'app/modules/dashboard/cubit/dashboard_cubit.dart';
import 'app/modules/pedidos/cubit/pedidos_cubit.dart';
import 'app/modules/produtos/cubit/produtos_cubit.dart';
import 'app/modules/loja/cubit/loja_cubit.dart';
import 'app/modules/cardapio/bloc/cardapio_cubit.dart';
import 'app/modules/onboarding/bloc/onboarding_cubit.dart';
import 'app/modules/configuracoes/bloc/configuracoes_cubit.dart';
import 'app/modules/store/bloc/store_cubit.dart';
import 'app/routes/app_routes.dart';

import 'app/modules/home/cubit/home_cubit.dart';
import 'app/core/api_client.dart';
import 'app/core/services/fcm_service.dart';
import 'app/core/navigation/navigation_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔥 INICIALIZA FIREBASE APENAS EM PLATAFORMAS SUPORTADAS (OU COM OPÇÕES CORRETAS)
  if (kIsWeb || !Platform.isWindows) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    debugPrint('[MAIN] ⏳ Ignorando Firebase.initializeApp no Windows');
  }
  
  await setupDependencies();
  
  // 🔥 INICIALIZA FCM
  await getIt<FcmService>().init();
  
  runApp(const QuiMandaApp());
}

class QuiMandaApp extends StatelessWidget {
  const QuiMandaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingCubit>(create: (context) => getIt<OnboardingCubit>()..checkOnboarding()),
        BlocProvider<AuthCubit>(create: (context) => getIt<AuthCubit>()..checkAuthStatus()),
        BlocProvider<StoreCubit>(create: (context) => getIt<StoreCubit>()..loadStores()),
        BlocProvider<HomeCubit>(create: (context) => getIt<HomeCubit>()),
        BlocProvider<DashboardCubit>(create: (context) => getIt<DashboardCubit>()),
        BlocProvider<PedidosCubit>(create: (context) => getIt<PedidosCubit>()),
        BlocProvider<ProdutosCubit>(create: (context) => getIt<ProdutosCubit>()),
        BlocProvider<CardapioCubit>(create: (context) => getIt<CardapioCubit>()),
        BlocProvider<LojaCubit>(create: (context) => getIt<LojaCubit>()),
        BlocProvider<ConfiguracoesCubit>(create: (context) => getIt<ConfiguracoesCubit>()),
      ],
      child: MaterialApp(
        title: 'QuiManda',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        builder: (context, child) {
          // 🔥 PASSA O CONTEXTO PARA O FCM PARA MOSTRAR OVERLAYS
          FcmService().context = context;

          return BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                // Redireciona para a tela inicial de autenticação
                ApiClient.navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  AppRoutes.phoneInput,
                  (route) => false,
                );
              }
            },
            child: child!,
          );
        },
      ),
    );
  }
}
