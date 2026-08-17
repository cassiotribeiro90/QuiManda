import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../pedidos/views/pedidos_list_page.dart';
import '../../produtos/views/produtos_list_view.dart';
import '../../loja/views/loja_edit_view.dart';
import 'widgets/side_menu.dart';

class HomeView extends StatefulWidget {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const double kDesktopBreakpoint = 900.0;

  final List<Widget> _pages = [
    const DashboardView(),
    const PedidosListPage(),
    const ProdutosListView(), // Representando "Cardápio"
    const Center(child: Scaffold(body: Center(child: Text('Módulo de Estoque (Em breve)')))),
    const LojaEditView(), // Representando "Configurações"
  ];

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
                      child: IndexedStack(
                        index: currentIndex,
                        children: _pages,
                      ),
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
              body: IndexedStack(
                index: currentIndex,
                children: _pages,
              ),
            );
          },
        );
      },
    );
  }
}
