import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/side_menu.dart';
import '../../store/bloc/store_cubit.dart';
import '../../store/bloc/store_state.dart';
import '../../pedidos/cubit/pedidos_cubit.dart';
import '../../dashboard/cubit/dashboard_cubit.dart';

class HomeView extends StatefulWidget {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Widget child;

  const HomeView({super.key, required this.child});

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
      debugPrint('🏠 [HOME] Carregando dados para a loja: ${storeState.selectedStore.nome}');
      
      context.read<PedidosCubit>().loadPedidosAtivosWithStoreCheck(storeId);
      context.read<DashboardCubit>().loadDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StoreCubit, StoreState>(
          listenWhen: (previous, current) {
            if (previous is StoreLoaded && current is StoreLoaded) {
              return previous.selectedStore.id != current.selectedStore.id;
            }
            return false;
          },
          listener: (context, state) {
            if (state is StoreLoaded) {
              debugPrint('🔄 [HOME] Loja mudou para ${state.selectedStore.nome}! Recarregando...');
              context.read<PedidosCubit>().reloadForStoreChange();
              context.read<DashboardCubit>().loadDashboard();
            }
          },
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;

          if (isDesktop) {
            return Scaffold(
              body: Row(
                children: [
                  const SideMenu(),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(
                    child: widget.child, // Exibe a rota atual injetada pelo ShellRoute
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
            body: widget.child, // Exibe a rota atual injetada pelo ShellRoute
          );
        },
      ),
    );
  }
}
