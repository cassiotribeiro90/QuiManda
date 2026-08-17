import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_cubit.dart';
import '../bloc/onboarding_state.dart';
import '../models/onboarding_model.dart';
import '../widgets/onboarding_button.dart';
import '../widgets/onboarding_indicator.dart';
import '../../../routes/app_routes.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      title: 'Bem-vindo ao QuiManda',
      description: 'Sua plataforma completa para gerenciar pedidos de forma rápida e eficiente.',
      image: 'assets/images/onboarding1.png',
    ),
    const OnboardingPage(
      title: 'Gerencie sua Loja',
      description: 'Controle seu estoque, atualize preços e visualize suas vendas em tempo real.',
      image: 'assets/images/onboarding2.png',
    ),
    const OnboardingPage(
      title: 'Comece Agora',
      description: 'Tudo o que você precisa para fazer seu negócio crescer na palma da sua mão.',
      image: 'assets/images/onboarding3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingSeen) {
          final authState = context.read<AuthCubit>().state;
          if (authState is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.phoneInput);
          }
        }
      },
      builder: (context, state) {
        if (state is OnboardingInitial || state is OnboardingLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is OnboardingSeen) {
          return const Scaffold(body: SizedBox.shrink());
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 300,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Icon(
                                  index == 0
                                      ? Icons.storefront
                                      : index == 1
                                          ? Icons.assignment
                                          : Icons.trending_up,
                                  size: 100,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              page.title,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              page.description,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      OnboardingIndicator(
                        itemCount: _pages.length,
                        currentIndex: _currentPage,
                      ),
                      const SizedBox(height: 40),
                      OnboardingButton(
                        text: _currentPage == _pages.length - 1 ? 'Começar' : 'Próximo',
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          } else {
                            context.read<OnboardingCubit>().markOnboardingAsSeen();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
