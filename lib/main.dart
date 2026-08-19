import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'app/routes/app_routes.dart';

import 'app/modules/home/cubit/home_cubit.dart';
import 'app/core/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
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
        navigatorKey: ApiClient.navigatorKey,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        builder: (context, child) {
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
