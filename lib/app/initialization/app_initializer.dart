import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../modules/auth/cubit/auth_cubit.dart';
import '../di/dependencies.dart';
import '../core/services/fcm_service.dart';

/// Widget responsável por inicializar o app antes da navegação
class AppInitializer extends StatefulWidget {
  final Widget child;

  const AppInitializer({super.key, required this.child});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    debugPrint('🚀 [INIT] Inicializando aplicação quiManda...');
    
    // ⚠️ Dispara a verificação de autenticação e serviços após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint('✅ [INIT] Disparando checkAuthStatus no AuthCubit...');
        context.read<AuthCubit>().checkAuthStatus();

        // 🔥 Inicializa FCM de forma assíncrona para não travar a tela
        debugPrint('🔔 [INIT] Inicializando FCM Service (background)...');
        getIt<FcmService>().init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ NÃO RENDERIZA SPLASH AQUI - Deixa o GoRouter cuidar da rota inicial
    return widget.child;
  }
}
