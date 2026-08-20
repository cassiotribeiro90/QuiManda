import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../store/bloc/store_cubit.dart';
import '../../../store/bloc/store_state.dart';
import '../../cubit/home_cubit.dart';


class SideMenu extends StatelessWidget {
  final bool isDrawer;

  const SideMenu({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 260,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Header
          BlocBuilder<StoreCubit, StoreState>(
            builder: (context, state) {
              String storeName = 'QuiManda';
              String storeAddress = 'Painel do Lojista';
              
              if (state is StoreLoaded) {
                storeName = state.selectedStore.nome;
                storeAddress = state.selectedStore.cidade ?? 'Painel do Lojista';
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.delivery_dining, size: 48, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      storeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      storeAddress,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Menu Items
          Expanded(
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                int currentIndex = 0;
                if (state is HomeModuleChanged) {
                  currentIndex = state.index;
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.dashboard,
                      label: 'Dashboard',
                      index: 0,
                      isSelected: currentIndex == 0,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.receipt_long,
                      label: 'Pedidos',
                      index: 1,
                      isSelected: currentIndex == 1,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.restaurant_menu,
                      label: 'Cardápio',
                      index: 2,
                      isSelected: currentIndex == 2,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings,
                      label: 'Configurações',
                      index: 3,
                      isSelected: currentIndex == 3,
                    ),
                    
                    const Divider(),
                    
                    BlocBuilder<StoreCubit, StoreState>(
                      builder: (context, storeState) {
                        if (storeState is StoreLoaded && storeState.hasMultipleStores) {
                          return ListTile(
                            leading: const Icon(Icons.storefront, color: Colors.blue),
                            title: const Text(
                              'Trocar Loja',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            onTap: () {
                              print('[UI_NAV] Abrindo seleção de lojas pelo menu');
                              if (isDrawer) {
                                Navigator.pop(context);
                              }
                              Navigator.pushNamed(context, AppRoutes.storeSelection);
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text(
                        'Sair',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        context.read<AuthCubit>().logout();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? theme.primaryColor : theme.iconTheme.color?.withValues(alpha: 0.7),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: theme.primaryColor.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          context.read<HomeCubit>().changeModule(index, label);
          if (isDrawer) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
