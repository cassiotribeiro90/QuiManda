import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dashboard/views/dashboard_screen.dart';
import '../cubit/home_cubit.dart';
import '../../pedidos/views/pedidos_list_page.dart';
import '../../cardapio/views/cardapio_page.dart';
import '../../configuracoes/views/configuracoes_loja_page.dart';
import 'widgets/side_menu.dart';
import '../../store/bloc/store_cubit.dart';
import '../../store/bloc/store_state.dart';
import '../../pedidos/cubit/pedidos_cubit.dart';
import '../../dashboard/cubit/dashboard_cubit.dart';

class HomeView extends StatefulWidget {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const double kDesktopBreakpoint = 900.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataForSelectedStore();
    });
  }

  void _loadDataForSelectedStore() {
    final storeState = context.read<StoreCubit>().state;
    if (storeState is StoreLoaded) {
      final storeId = storeState.selectedStore.id;
      print('[HOME] Carregando dados para a loja: ${storeState.selectedStore.nome}');
      
      // 🔥 RECARREGA OS PEDIDOS DA LOJA ATUAL
      context.read<PedidosCubit>().loadPedidosAtivosWithStoreCheck(storeId);
      
      // 🔥 RECARREGA O DASHBOARD
      context.read<DashboardCubit>().loadDashboard();
    }
  }

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
    return MultiBlocListener(
      listeners: [
        // 🔥 ESCUTA MUDANÇAS NA LOJA PARA RECARREGAR DADOS
        BlocListener<StoreCubit, StoreState>(
          listenWhen: (previous, current) {
            if (previous is StoreLoaded && current is StoreLoaded) {
              return previous.selectedStore.id != current.selectedStore.id;
            }
            return false;
          },
          listener: (context, state) {
            if (state is StoreLoaded) {
              print('[HOME] Loja mudou para ${state.selectedStore.nome}! Recarregando tudo...');
              
              // 🔥 RECARREGA OS PEDIDOS COM A NOVA LOJA
              context.read<PedidosCubit>().reloadForStoreChange();
              
              // 🔥 RECARREGA O DASHBOARD
              context.read<DashboardCubit>().loadDashboard();
            }
          },
        ),
      ],
      child: BlocBuilder<HomeCubit, HomeState>(
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
      ),
    );
  }
}
