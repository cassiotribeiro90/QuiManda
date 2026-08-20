import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../onboarding/bloc/onboarding_cubit.dart';
import '../../onboarding/bloc/onboarding_state.dart';
import '../../../routes/app_routes.dart';

import '../../store/bloc/store_cubit.dart';
import '../../store/bloc/store_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    // Garantir tempo mínimo de splash
    final startTime = DateTime.now();
    
    await context.read<OnboardingCubit>().checkOnboarding();
    await context.read<AuthCubit>().checkAuthStatus();
    
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed.inMilliseconds < 1500) {
      await Future.delayed(Duration(milliseconds: 1500 - elapsed.inMilliseconds));
    }
    
    _checkNavigation();
  }

  void _checkNavigation() {
    if (!mounted) return;

    final authState = context.read<AuthCubit>().state;
    final onboardingState = context.read<OnboardingCubit>().state;
    final storeState = context.read<StoreCubit>().state;

    print('[SPLASH] Verificando navegação: Auth=$authState, Onboarding=$onboardingState, Store=$storeState');

    // Só navega se ambos saíram do estado inicial
    if (onboardingState is OnboardingInitial || authState is AuthInitial || storeState is StoreInitial) {
      return;
    }

    if (onboardingState is OnboardingNotSeen) {
      print('[SPLASH] Onboarding não visto, redirecionando');
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    } else {
      if (authState is AuthAuthenticated) {
        if (storeState is StoreLoaded) {
          print('[SPLASH] Autenticado com ${storeState.stores.length} lojas');
          if (storeState.hasMultipleStores) {
            print('[SPLASH] Múltiplas lojas detectadas, forçando seleção');
            Navigator.pushReplacementNamed(context, AppRoutes.storeSelection);
          } else {
            print('[SPLASH] Apenas uma loja, indo para Dashboard');
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          }
        } else {
          print('[SPLASH] Autenticado mas sem lojas carregadas, indo para Dashboard');
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        }
      } else {
        print('[SPLASH] Não autenticado, indo para PhoneInput');
        Navigator.pushReplacementNamed(context, AppRoutes.phoneInput);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) => _checkNavigation(),
        ),
        BlocListener<OnboardingCubit, OnboardingState>(
          listener: (context, state) => _checkNavigation(),
        ),
      ],
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delivery_dining, size: 100, color: Colors.white),
              SizedBox(height: 24),
              Text(
                'QuiManda',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Gestão de Delivery',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
