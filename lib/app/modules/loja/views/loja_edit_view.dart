import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/loja_cubit.dart';
import '../cubit/loja_state.dart';
import '../model/loja_model.dart';

import '../../home/views/home_view.dart';

class LojaEditView extends StatefulWidget {
  const LojaEditView({super.key});

  @override
  State<LojaEditView> createState() => _LojaEditViewState();
}

class _LojaEditViewState extends State<LojaEditView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _enderecoController;
  late TextEditingController _telefoneController;
  bool _aberta = true;

  @override
  void initState() {
    super.initState();
    context.read<LojaCubit>().loadLoja();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja'),
        leading: LayoutBuilder(
          builder: (context, constraints) {
            if (MediaQuery.of(context).size.width < 900) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => HomeView.scaffoldKey.currentState?.openDrawer(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      body: BlocConsumer<LojaCubit, LojaState>(
        listener: (context, state) {
          if (state is LojaLoaded) {
            _nomeController = TextEditingController(text: state.loja.nome);
            _enderecoController = TextEditingController(text: state.loja.endereco);
            _telefoneController = TextEditingController(text: state.loja.telefone);
            _aberta = state.loja.aberta;
          }
        },
        builder: (context, state) {
          if (state is LojaLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LojaLoaded || state is LojaInitial) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(labelText: 'Nome da Loja'),
                      validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _enderecoController,
                      decoration: const InputDecoration(labelText: 'Endereço'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefoneController,
                      decoration: const InputDecoration(labelText: 'Telefone'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Loja Aberta para Pedidos'),
                      value: _aberta,
                      onChanged: (value) => setState(() => _aberta = value),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final updatedLoja = LojaModel(
                            id: (state is LojaLoaded) ? state.loja.id : '1',
                            nome: _nomeController.text,
                            endereco: _enderecoController.text,
                            telefone: _telefoneController.text,
                            aberta: _aberta,
                          );
                          context.read<LojaCubit>().updateLoja(updatedLoja);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Configurações salvas!')),
                          );
                        }
                      },
                      child: const Text('SALVAR ALTERAÇÕES'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
