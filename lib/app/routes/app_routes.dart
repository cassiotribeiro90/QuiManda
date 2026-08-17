import 'package:flutter/material.dart';
import '../modules/auth/views/splash_page.dart';
import '../modules/auth/views/phone_input_page.dart';
import '../modules/auth/views/otp_verification_page.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/onboarding/views/onboarding_view.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String phoneInput = '/phone-input';
  static const String otpVerify = '/otp-verify';
  static const String dashboard = '/dashboard';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashPage(),
    onboarding: (context) => const OnboardingView(),
    phoneInput: (context) => const PhoneInputPage(),
    otpVerify: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return OtpVerificationPage(telefone: args['telefone'] as String);
    },
    dashboard: (context) => const HomeView(),
  };
}
