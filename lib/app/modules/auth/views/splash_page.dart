import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../onboarding/bloc/onboarding_cubit.dart';
import '../../onboarding/bloc/onboarding_state.dart';
import '../../../routes/app_routes.dart';

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
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    await context.read<OnboardingCubit>().checkOnboarding();
    await context.read<AuthCubit>().checkAuthStatus();
    
    _checkNavigation();
  }

  void _checkNavigation() {
    if (!mounted) return;

    final authState = context.read<AuthCubit>().state;
    
    if (authState is AuthAuthenticated || authState is AuthUnauthenticated || authState is AuthError) {
      _navigate(authState);
    }
  }

  void _navigate(AuthState authState) {
    if (!mounted) return;

    final onboardingState = context.read<OnboardingCubit>().state;

    if (onboardingState is OnboardingNotSeen) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    } else {
      if (authState is AuthAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.phoneInput);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthUnauthenticated || state is AuthError) {
          _navigate(state);
        }
      },
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
