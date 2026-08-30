import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../chat/bloc/chat_badge_cubit.dart';
import '../../../store/bloc/store_cubit.dart';
import '../../../store/bloc/store_state.dart';
import '../../../../navigation/navigation_cubit.dart';

class SideMenu extends StatefulWidget {
  final bool isDrawer;

  const SideMenu({super.key, this.isDrawer = false});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  Timer? _badgeTimer;

  @override
  void initState() {
    super.initState();
    _badgeTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      context.read<ChatBadgeCubit>().updateBadge();
    });
  }

  @override
  void dispose() {
    _badgeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nav = context.read<NavigationCubit>();

    return Container(
      width: 280,
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
            child: Builder(
              builder: (context) {
                final String location = GoRouterState.of(context).uri.toString();
                int currentIndex = -1;
                if (location.endsWith('/pedidos')) {
                  currentIndex = 0;
                } else if (location.contains('all-pedidos')) {
                  currentIndex = 5;
                } else if (location.contains('dashboard')) {
                  currentIndex = 1;
                } else if (location.contains('cardapio')) {
                  currentIndex = 2;
                } else if (location.contains('chat-genericos')) {
                  currentIndex = 3;
                } else if (location.contains('configuracoes')) {
                  currentIndex = 4;
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.receipt_long,
                      label: 'Acompanhar Pedidos',
                      route: '/pedidos',
                      isSelected: currentIndex == 0,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.list_alt,
                      label: 'Todos os Pedidos',
                      route: '/all-pedidos',
                      isSelected: currentIndex == 5,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.dashboard,
                      label: 'Dashboard',
                      route: '/dashboard',
                      isSelected: currentIndex == 1,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.restaurant_menu,
                      label: 'Cardápio',
                      route: '/cardapio',
                      isSelected: currentIndex == 2,
                    ),
                    
                    // 🔥 ATUALIZADO: CHATS COM CHATBADGECUBIT
                    BlocBuilder<ChatBadgeCubit, int>(
                      builder: (context, badgeCount) {
                        return _buildChatMenuItem(
                          context,
                          icon: Icons.chat_bubble_outline,
                          label: 'Conversas com clientes',
                          route: '/chat-genericos',
                          isSelected: currentIndex == 3,
                          badgeCount: badgeCount,
                        );
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Icons.settings,
                      label: 'Configurações',
                      route: '/configuracoes',
                      isSelected: currentIndex == 4,
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
                            subtitle: Text(
                              'Atual: ${storeState.selectedStore.nome}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            onTap: () {
                              debugPrint('🏪 [UI_NAV] Abrindo seleção de lojas pelo menu');
                              if (widget.isDrawer) {
                                nav.pop();
                              }
                              nav.goToStoreSelection();
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
                        debugPrint('🔐 [AUTH] Logout solicitado via menu');
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
        required String route,
        required bool isSelected,
      }) {
    final theme = Theme.of(context);
    final nav = context.read<NavigationCubit>();

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
          debugPrint('🔄 [UI_NAV] Navegando para rota: $route');
          nav.go(route);

          if (widget.isDrawer) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  // 🔥 ITEM DO MENU COM BADGE
  Widget _buildChatMenuItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String route,
        required bool isSelected,
        required int badgeCount,
      }) {
    final theme = Theme.of(context);
    final nav = context.read<NavigationCubit>();

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
        // 🔥 TRAILING COM BADGE
        trailing: badgeCount > 0
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          constraints: const BoxConstraints(
            minWidth: 24,
            minHeight: 24,
          ),
          child: Text(
            badgeCount > 99 ? '99+' : '$badgeCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        )
            : null,
        selected: isSelected,
        selectedTileColor: theme.primaryColor.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          debugPrint('🔄 [UI_NAV] Navegando para rota: $route');
          nav.go(route);

          if (widget.isDrawer) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}