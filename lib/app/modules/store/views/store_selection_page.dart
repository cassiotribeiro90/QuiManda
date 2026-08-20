import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/store_cubit.dart';
import '../bloc/store_state.dart';
import '../../../routes/app_routes.dart';

class StoreSelectionPage extends StatefulWidget {
  const StoreSelectionPage({super.key});

  @override
  State<StoreSelectionPage> createState() => _StoreSelectionPageState();
}

class _StoreSelectionPageState extends State<StoreSelectionPage> {
  @override
  void initState() {
    super.initState();
    print('[UI] StoreSelectionPage aberta');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione a Loja'),
        centerTitle: true,
      ),
      body: BlocBuilder<StoreCubit, StoreState>(
        builder: (context, state) {
          print('[UI] Estado da loja na seleção: $state');
          if (state is StoreLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StoreLoaded) {
            return ListView.builder(
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
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.shade200,
                      child: Icon(
                        isSelected ? Icons.check : Icons.store,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                    title: Text(
                      loja.nome,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        loja.enderecoCompleto,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.radio_button_checked, color: Theme.of(context).primaryColor)
                        : const Icon(Icons.radio_button_off, color: Colors.grey),
                    onTap: () {
                      print('[UI] Loja selecionada: ${loja.nome} (ID: ${loja.id})');
                      context.read<StoreCubit>().selectStore(loja.id);
                      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                    },
                  ),
                );
              },
            );
          }
          if (state is StoreEmpty) {
            return const Center(child: Text('Nenhuma loja vinculada à sua conta.'));
          }
          if (state is StoreError) {
            return Center(child: Text('Erro ao carregar lojas: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
