import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_strategy/url_strategy.dart';
import 'app/core/theme/app_theme.dart';
import 'app/di/dependencies.dart';
import 'app/modules/auth/cubit/auth_cubit.dart';
import 'app/modules/dashboard/cubit/dashboard_cubit.dart';
import 'app/modules/pedidos/cubit/pedidos_cubit.dart';
import 'app/modules/produtos/cubit/produtos_cubit.dart';
import 'app/modules/loja/cubit/loja_cubit.dart';
import 'app/modules/cardapio/bloc/cardapio_cubit.dart';
import 'app/modules/onboarding/bloc/onboarding_cubit.dart';
import 'app/modules/configuracoes/bloc/configuracoes_cubit.dart';
import 'app/modules/chat/bloc/chat_bloc.dart';
import 'app/modules/chat/bloc/chat_badge_cubit.dart';
import 'app/modules/store/bloc/store_cubit.dart';
import 'app/routes/app_router.dart';
import 'app/navigation/navigation_cubit.dart';
import 'app/navigation/app_router_listener.dart';
import 'app/initialization/app_initializer.dart';
import 'app/modules/home/cubit/home_cubit.dart';
import 'app/core/services/fcm_service.dart';
import 'firebase_options.dart';

void main() async {
  debugPrint('🚀 [MAIN] Iniciando aplicação quiManda...');
  WidgetsFlutterBinding.ensureInitialized();
  
  setPathUrlStrategy();
  debugPrint('🌐 [MAIN] URL Strategy configurada');
  
  if (kIsWeb || !Platform.isWindows) {
    debugPrint('🔥 [MAIN] Inicializando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  debugPrint('📦 [MAIN] Configurando injeção de dependências...');
  await setupDependencies();
  
  runApp(const QuiMandaApp());
  debugPrint('✅ [MAIN] App carregado com sucesso');
}

class QuiMandaApp extends StatelessWidget {
  const QuiMandaApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('📱 [MAIN] Construindo QuiMandaApp');
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationCubit>(create: (context) => NavigationCubit()),
        BlocProvider<OnboardingCubit>(create: (context) => getIt<OnboardingCubit>()..checkOnboarding()),
        BlocProvider<AuthCubit>(create: (context) => getIt<AuthCubit>()),
        BlocProvider<StoreCubit>(create: (context) => getIt<StoreCubit>()),
        BlocProvider<HomeCubit>(create: (context) => getIt<HomeCubit>()),
        BlocProvider<DashboardCubit>(create: (context) => getIt<DashboardCubit>()),
        BlocProvider<PedidosCubit>(create: (context) => getIt<PedidosCubit>()),
        BlocProvider<ProdutosCubit>(create: (context) => getIt<ProdutosCubit>()),
        BlocProvider<CardapioCubit>(create: (context) => getIt<CardapioCubit>()),
        BlocProvider<LojaCubit>(create: (context) => getIt<LojaCubit>()),
        BlocProvider<ConfiguracoesCubit>(create: (context) => getIt<ConfiguracoesCubit>()),
        BlocProvider<ChatBadgeCubit>(create: (context) => getIt<ChatBadgeCubit>()..updateBadge()),
        BlocProvider<ChatBloc>(create: (context) => ChatBloc()),
      ],
      child: AppInitializer(
        child: MaterialApp.router(
          title: 'QuiManda',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          builder: (context, child) {
            // 🔥 Injeta o contexto no FCM
            FcmService().context = context;

            // ⚠️ O AppRouterListener DEVE estar DENTRO do MaterialApp para acessar o GoRouter
            return AppRouterListener(
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}
