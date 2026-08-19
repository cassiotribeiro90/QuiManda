import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dashboard/views/dashboard_screen.dart';
import '../cubit/home_cubit.dart';
import '../../pedidos/views/pedidos_list_page.dart';
import '../../cardapio/views/cardapio_page.dart';
import '../../configuracoes/views/configuracoes_loja_page.dart';
import 'widgets/side_menu.dart';

class HomeView extends StatefulWidget {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const double kDesktopBreakpoint = 900.0;

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const PedidosListPage();
      case 2:
        return const CardapioPage();
      case 3:
        return const ConfiguracoesLojaPage();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        int currentIndex = 0;

        if (state is HomeModuleChanged) {
          currentIndex = state.index;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;

            if (isDesktop) {
              return Scaffold(
                body: Row(
                  children: [
                    const SideMenu(),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(
                      child: _buildPage(currentIndex),
                    ),
                  ],
                ),
              );
            }

            // Layout Mobile com Drawer
            return Scaffold(
              key: HomeView.scaffoldKey,
              drawer: const Drawer(
                child: SideMenu(isDrawer: true),
              ),
              body: _buildPage(currentIndex),
            );
          },
        );
      },
    );
  }
}
