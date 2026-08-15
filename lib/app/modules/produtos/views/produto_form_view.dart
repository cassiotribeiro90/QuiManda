import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/produtos_cubit.dart';
import '../model/produto_model.dart';

class ProdutoFormView extends StatefulWidget {
  final ProdutoModel? produto;

  const ProdutoFormView({super.key, this.produto});

  @override
  State<ProdutoFormView> createState() => _ProdutoFormViewState();
}

class _ProdutoFormViewState extends State<ProdutoFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _precoController;
  bool _disponivel = true;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.produto?.nome ?? '');
    _descricaoController = TextEditingController(text: widget.produto?.descricao ?? '');
    _precoController = TextEditingController(text: widget.produto?.preco.toString() ?? '');
    _disponivel = widget.produto?.disponivel ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.produto == null ? 'Novo Produto' : 'Editar Produto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(labelText: 'Preço', prefixText: 'R\$ '),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || double.tryParse(value) == null ? 'Preço inválido' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Disponível'),
                value: _disponivel,
                onChanged: (value) => setState(() => _disponivel = value),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final novoProduto = ProdutoModel(
                      id: widget.produto?.id ?? '',
                      nome: _nomeController.text,
                      descricao: _descricaoController.text,
                      preco: double.parse(_precoController.text),
                      disponivel: _disponivel,
                    );
                    context.read<ProdutosCubit>().saveProduto(novoProduto);
                    Navigator.pop(context);
                  }
                },
                child: const Text('SALVAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
