import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/store_cubit.dart';
import '../bloc/store_state.dart';
import '../../../navigation/navigation_cubit.dart';
import '../../../core/responsive/responsive_scaffold.dart';

class StoreSelectionPage extends StatefulWidget {
  const StoreSelectionPage({super.key});

  @override
  State<StoreSelectionPage> createState() => _StoreSelectionPageState();
}

class _StoreSelectionPageState extends State<StoreSelectionPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('🏪 [UI] StoreSelectionPage aberta');
    // Carrega as lojas se ainda não estiverem carregadas
    final state = context.read<StoreCubit>().state;
    if (state is StoreInitial || state is StoreEmpty) {
      context.read<StoreCubit>().loadStores();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationCubit>();
    return ResponsiveScaffold(
      maxWidth: 800,
      appBar: AppBar(
        title: const Text(
          'Selecione a Loja',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            debugPrint('⬅️ [NAVIGATION] Cancelando seleção de loja');
            // Se veio de uma tela anterior, volta
            if (Navigator.canPop(context)) {
              nav.pop();
            } else {
              // Se não tem tela anterior, vai para o dashboard
              nav.goToDashboard();
            }
          },
          tooltip: 'Cancelar',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              debugPrint('🔄 [UI] Solicitando recarregamento de lojas');
              context.read<StoreCubit>().loadStores();
            },
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: BlocBuilder<StoreCubit, StoreState>(
        builder: (context, state) {
          debugPrint('🔄 [UI] Estado da loja na seleção: ${state.runtimeType}');

          if (state is StoreLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando lojas...'),
                ],
              ),
            );
          }

          if (state is StoreLoaded) {
            if (state.stores.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Nenhuma loja vinculada',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Entre em contato com o administrador',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Header informativo
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.stores.length > 1
                                ? 'Selecione a loja que deseja gerenciar'
                                : 'Você possui apenas uma loja. Ela será selecionada automaticamente.',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Lista de lojas
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.stores.length,
                    itemBuilder: (context, index) {
                      final loja = state.stores[index];
                      final isSelected = loja.id == state.selectedStore.id;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: isSelected ? 4 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSelected
                              ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                              : BorderSide.none,
                        ),
                        child: InkWell(
                          onTap: () {
                            debugPrint('🏪 [UI] Loja selecionada: ${loja.nome} (ID: ${loja.id})');
                            context.read<StoreCubit>().selectStore(loja.id);
                            nav.goToDashboard();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Ícone da loja
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isSelected ? Icons.check_circle : Icons.storefront,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey.shade600,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Informações da loja
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loja.nome,
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          fontSize: 16,
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        loja.enderecoCompleto,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (loja.telefone != null && loja.telefone!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            '📞 ${loja.telefone}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Indicador de seleção
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          if (state is StoreEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma loja vinculada',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entre em contato com o administrador',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      debugPrint('🔄 [UI] Tentando recarregar lojas após lista vazia');
                      context.read<StoreCubit>().loadStores();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is StoreError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar lojas',
                    style: TextStyle(fontSize: 18, color: Colors.red.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      debugPrint('🔄 [UI] Tentando recarregar lojas após erro');
                      context.read<StoreCubit>().loadStores();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
