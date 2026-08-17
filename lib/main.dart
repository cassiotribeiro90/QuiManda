import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/core/theme.dart';
import 'app/di/dependencies.dart';
import 'app/modules/auth/cubit/auth_cubit.dart';
import 'app/modules/dashboard/cubit/dashboard_cubit.dart';
import 'app/modules/pedidos/cubit/pedidos_cubit.dart';
import 'app/modules/produtos/cubit/produtos_cubit.dart';
import 'app/modules/loja/cubit/loja_cubit.dart';
import 'app/modules/onboarding/bloc/onboarding_cubit.dart';
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
        BlocProvider<AuthCubit>(create: (context) => getIt<AuthCubit>()),
        BlocProvider<HomeCubit>(create: (context) => getIt<HomeCubit>()),
        BlocProvider<DashboardCubit>(create: (context) => getIt<DashboardCubit>()),
        BlocProvider<PedidosCubit>(create: (context) => getIt<PedidosCubit>()),
        BlocProvider<ProdutosCubit>(create: (context) => getIt<ProdutosCubit>()),
        BlocProvider<LojaCubit>(create: (context) => getIt<LojaCubit>()),
      ],
      child: MaterialApp(
        title: 'QuiManda',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: ApiClient.navigatorKey,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
