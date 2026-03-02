import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quimanda/app/modules/dashboard/views/dashboard_screen.dart';
import 'package:quimanda/app/modules/deliveries/views/deliveries_screen.dart';
import 'package:quimanda/app/modules/entregadores/views/delivery_persons_screen.dart';
import 'package:quimanda/app/modules/lojas/views/stores_screen.dart';
import 'package:quimanda/app/modules/settings/views/settings_screen.dart';
import '../../../theme/app_theme.dart';
import '../cubit/home_cubit.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, int>(
      builder: (context, selectedIndex) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth > 800;

            if (isWeb) {
              return Row(
                children: [
                  _buildSidebar(context, selectedIndex),
                  Expanded(child: _getScreen(selectedIndex)),
                ],
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('quiManda'),
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                ),
                drawer: Drawer(child: _buildMobileMenu(context, selectedIndex)),
                body: _getScreen(selectedIndex),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context, int selectedIndex) {
    return Container(
      width: 280,
      color: AppTheme.surfaceColor,
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text('Q', style: TextStyle(color: Colors.white, fontSize: 24))),
                ),
                const SizedBox(width: 12),
                const Text('quiManda', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Menu Itens
          ..._buildMenuItems(context, selectedIndex),
        ],
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0: return const DashboardScreen();
      case 1: return const DeliveriesScreen();
      case 2: return const DeliveryPersonsScreen();
      case 3: return const StoresScreen();
      case 4: return const SettingsScreen();
      default: return const DashboardScreen();
    }
  }

  List<Widget> _buildMenuItems(BuildContext context, int selectedIndex) {
    return [
      ListTile(
        leading: const Icon(Icons.dashboard),
        title: const Text('Dashboard'),
        selected: selectedIndex == 0,
        onTap: () => context.read<HomeCubit>().setIndex(0),
      ),
      ListTile(
        leading: const Icon(Icons.delivery_dining),
        title: const Text('Entregas'),
        selected: selectedIndex == 1,
        onTap: () => context.read<HomeCubit>().setIndex(1),
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Entregadores'),
        selected: selectedIndex == 2,
        onTap: () => context.read<HomeCubit>().setIndex(2),
      ),
      ListTile(
        leading: const Icon(Icons.store),
        title: const Text('Lojas'),
        selected: selectedIndex == 3,
        onTap: () => context.read<HomeCubit>().setIndex(3),
      ),
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Configurações'),
        selected: selectedIndex == 4,
        onTap: () => context.read<HomeCubit>().setIndex(4),
      ),
    ];
  }

  Widget _buildMobileMenu(BuildContext context, int selectedIndex) {
    return ListView(
      children: _buildMenuItems(context, selectedIndex),
    );
  }
}
