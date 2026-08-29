import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/responsive/responsive_scaffold.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/cardapio_cubit.dart';
import '../bloc/cardapio_state.dart';
import '../models/produto_model.dart';
import '../models/categoria.dart';
import '../models/subcategoria.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../../navigation/navigation_cubit.dart';
import '../../../widgets/custom_app_bar.dart';

class FormularioProdutoPage extends StatefulWidget {
  final ProdutoModel? produto;

  const FormularioProdutoPage({super.key, this.produto});

  @override
  State<FormularioProdutoPage> createState() => _FormularioProdutoPageState();
}

class _FormularioProdutoPageState extends State<FormularioProdutoPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _precoController;
  late TextEditingController _precoPromocionalController;
  late TextEditingController _imagemController;
  late TextEditingController _ingredientesController;
  late TextEditingController _tempoPreparoController;
  late TextEditingController _ordemController;
  late TextEditingController _estoqueController;

  // IDs e seleções
  int? _categoriaId;
  int? _subcategoriaId;
  
  // Listas de opções
  List<Categoria> _categorias = [];
  List<Subcategoria> _subcategorias = [];
  bool _loadingSubcategorias = false;
  
  // Status
  bool _disponivel = true;
  bool _ativo = true;
  bool _destaque = false;
  bool _contemGluten = false;
  bool _contemLactose = false;
  bool _vegano = false;
  bool _vegetariano = false;
  bool _apimentado = false;
  
  bool _isEditing = false;
  bool _initialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.produto != null;
    debugPrint('📦 [CARDAPIO] Abrindo formulário de produto. Edição: $_isEditing');
    _inicializarControllers();
    
    // Load initial data
    context.read<CardapioCubit>().loadInitialData(produtoId: widget.produto?.id);
  }

  void _inicializarControllers() {
    final p = widget.produto;
    _nomeController = TextEditingController(text: p?.nome ?? '');
    _descricaoController = TextEditingController(text: p?.descricao ?? '');
    _precoController = TextEditingController(text: p?.preco.toString() ?? '');
    _precoPromocionalController = TextEditingController(text: p?.precoPromocional?.toString() ?? '');
    _imagemController = TextEditingController(text: p?.imagem ?? '');
    _ingredientesController = TextEditingController(text: p?.ingredientesTexto ?? '');
    _tempoPreparoController = TextEditingController(text: p?.tempoPreparoMin?.toString() ?? '');
    _ordemController = TextEditingController(text: p?.ordem.toString() ?? '0');
    _estoqueController = TextEditingController(text: p?.estoque?.toString() ?? '');
  }

  void _preencherControllers(ProdutoModel produto) {
    _nomeController.text = produto.nome;
    _descricaoController.text = produto.descricao ?? '';
    _precoController.text = produto.preco.toString();
    _precoPromocionalController.text = produto.precoPromocional?.toString() ?? '';
    _imagemController.text = produto.imagem ?? '';
    _ingredientesController.text = produto.ingredientesTexto ?? '';
    _tempoPreparoController.text = produto.tempoPreparoMin?.toString() ?? '';
    _ordemController.text = produto.ordem.toString();
    _estoqueController.text = produto.estoque?.toString() ?? '';
    
    _categoriaId = produto.categoriaId;
    _subcategoriaId = produto.subcategoriaId;
    
    _disponivel = produto.disponivel;
    _ativo = produto.ativo;
    _destaque = produto.destaque;
    _contemGluten = produto.contemGluten;
    _contemLactose = produto.contemLactose;
    _vegano = produto.vegano;
    _vegetariano = produto.vegetariano;
    _apimentado = produto.apimentado;
  }

  Future<void> _carregarSubcategorias(int categoriaId, {bool resetSelection = true}) async {
    setState(() {
      _loadingSubcategorias = true;
      if (resetSelection) {
        _subcategoriaId = null;
      }
      _subcategorias = [];
    });

    try {
      final subcategorias = await context.read<CardapioCubit>().loadSubcategorias(categoriaId);
      setState(() {
        _subcategorias = subcategorias;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar subcategorias: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingSubcategorias = false);
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _precoPromocionalController.dispose();
    _imagemController.dispose();
    _ingredientesController.dispose();
    _tempoPreparoController.dispose();
    _ordemController.dispose();
    _estoqueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CardapioCubit, CardapioState>(
      listener: (context, state) {
        if (state is CardapioOperationSuccess) {
          debugPrint('✅ [CARDAPIO] Operação realizada com sucesso: ${state.message}');
          context.read<NavigationCubit>().pop();
          // Recarrega a lista após voltar
          context.read<CardapioCubit>().carregarProdutos();
        } else if (state is CardapioError) {
          debugPrint('❌ [CARDAPIO] Erro na operação: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is CardapioFormLoaded) {
          debugPrint('📦 [CARDAPIO] Dados do formulário carregados');
          setState(() {
            _categorias = state.categorias;
            if (state.subcategorias.isNotEmpty) {
              _subcategorias = state.subcategorias;
            }
          });

          if (!_initialDataLoaded) {
            setState(() {
              if (state.produto != null) {
                _preencherControllers(state.produto!);
              }
              _initialDataLoaded = true;
            });

            if (_categoriaId != null) {
              _carregarSubcategorias(_categoriaId!, resetSelection: false);
            }
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is CardapioLoading || state is CardapioOperationLoading || _loadingSubcategorias;

        return ResponsiveScaffold(
          maxWidth: 900,
          appBar: CustomAppBar(
            title: _isEditing ? 'Editar Produto' : 'Novo Produto',
            leading: BackButton(
              color: Colors.white,
              onPressed: () {
                debugPrint('⬅️ [NAVIGATION] Voltando do formulário de produto');
                context.read<NavigationCubit>().pop();
              },
            ),
          ),
          body: (state is CardapioLoading && !_initialDataLoaded)
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildBasicInfoCard(context),
                        const SizedBox(height: 20),
                        _buildCategorizationCard(context),
                        const SizedBox(height: 20),
                        _buildImageCard(context),
                        const SizedBox(height: 20),
                        _buildStatusCard(context),
                        const SizedBox(height: 20),
                        _buildAdditionalInfoCard(context),
                        const SizedBox(height: 20),
                        _buildStockAndPrepCard(context),
                        const SizedBox(height: 32),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : _salvar,
                            icon: (state is CardapioOperationLoading) 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.save),
                            label: Text(_isEditing ? 'ATUALIZAR PRODUTO' : 'CRIAR PRODUTO', style: AppTextStyles.button),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.titleSmall,
        ),
      ],
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, icon: Icons.fastfood_outlined, title: 'Informações Básicas'),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(labelText: 'Nome do Produto *', prefixIcon: Icon(Icons.fastfood_outlined), border: OutlineInputBorder()),
            validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descricaoController,
            decoration: const InputDecoration(labelText: 'Descrição', prefixIcon: Icon(Icons.description_outlined), border: OutlineInputBorder()),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _precoController,
                  decoration: const InputDecoration(labelText: 'Preço (R\$) *', prefixIcon: Icon(Icons.attach_money), border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _precoPromocionalController,
                  decoration: const InputDecoration(labelText: 'Preço Promocional', prefixIcon: Icon(Icons.attach_money), border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorizationCard(BuildContext context) {
    final uniqueCategorias = {for (var cat in _categorias) cat.id: cat}.values.toList();
    
    int? effectiveCategoriaId = _categoriaId;
    if (effectiveCategoriaId != null && !uniqueCategorias.any((cat) => cat.id == effectiveCategoriaId)) {
      effectiveCategoriaId = null;
    }

    final uniqueSubcategorias = {for (var sub in _subcategorias) sub.id: sub}.values.toList();
    
    int? effectiveSubcategoriaId = _subcategoriaId;
    if (effectiveSubcategoriaId != null && !uniqueSubcategorias.any((sub) => sub.id == effectiveSubcategoriaId)) {
      effectiveSubcategoriaId = null;
    }

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, icon: Icons.category_outlined, title: 'Categorização'),
          const SizedBox(height: 20),
          
          DropdownButtonFormField<int?>(
            initialValue: effectiveCategoriaId,
            decoration: const InputDecoration(labelText: 'Categoria *', prefixIcon: Icon(Icons.category_outlined), border: OutlineInputBorder()),
            items: [
              const DropdownMenuItem(value: null, child: Text('Selecione uma categoria')),
              ...uniqueCategorias.map((cat) => DropdownMenuItem(
                value: cat.id,
                child: Row(children: [Text(cat.icone ?? ''), const SizedBox(width: 8), Text(cat.nome)]),
              )),
            ],
            onChanged: (id) {
              setState(() {
                _categoriaId = id;
                _subcategoriaId = null;
                _subcategorias = [];
              });
              if (id != null) {
                _carregarSubcategorias(id);
              }
            },
            validator: (value) => value == null ? 'Selecione uma categoria' : null,
          ),

          const SizedBox(height: 16),

          if (_loadingSubcategorias)
            const Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ))
          else
            DropdownButtonFormField<int?>(
              initialValue: effectiveSubcategoriaId,
              decoration: const InputDecoration(labelText: 'Subcategoria', prefixIcon: Icon(Icons.account_tree_outlined), border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem(value: null, child: Text('Sem subcategoria')),
                ...uniqueSubcategorias.map((sub) => DropdownMenuItem(
                  value: sub.id,
                  child: Text(sub.nome),
                )),
              ],
              onChanged: (value) => setState(() => _subcategoriaId = value),
            ),
        ],
      ),
    );
  }

  Widget _buildImageCard(BuildContext context) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, icon: Icons.image_outlined, title: 'Imagem'),
          const SizedBox(height: 20),
          TextFormField(
            controller: _imagemController,
            decoration: const InputDecoration(labelText: 'URL da Imagem', prefixIcon: Icon(Icons.link), border: OutlineInputBorder()),
            onChanged: (_) => setState(() {}),
          ),
          if (_imagemController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _imagemController.text,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Center(child: Text('Imagem inválida')),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, icon: Icons.info_outline, title: 'Status e Disponibilidade'),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Disponível para venda'),
            value: _disponivel,
            onChanged: (value) => setState(() => _disponivel = value),
            activeThumbColor: Colors.green,
          ),
          SwitchListTile(
            title: const Text('Produto Ativo'),
            value: _ativo,
            onChanged: (value) => setState(() => _ativo = value),
          ),
          SwitchListTile(
            title: const Text('Produto em Destaque'),
            value: _destaque,
            onChanged: (value) => setState(() => _destaque = value),
            activeThumbColor: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard(BuildContext context) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, icon: Icons.health_and_safety_outlined, title: 'Informações Adicionais'),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Contém Glúten'), 
                selected: _contemGluten, 
                onSelected: (v) => setState(() => _contemGluten = v),
                selectedColor: Colors.deepOrange.withValues(alpha: 0.2),
                checkmarkColor: Colors.deepOrange,
              ),
              FilterChip(
                label: const Text('Contém Lactose'), 
                selected: _contemLactose, 
                onSelected: (v) => setState(() => _contemLactose = v),
                selectedColor: Colors.deepOrange.withValues(alpha: 0.2),
                checkmarkColor: Colors.deepOrange,
              ),
              FilterChip(
                label: const Text('Vegano'), 
                selected: _vegano, 
                onSelected: (v) => setState(() => _vegano = v),
                selectedColor: Colors.deepOrange.withValues(alpha: 0.2),
                checkmarkColor: Colors.deepOrange,
              ),
              FilterChip(
                label: const Text('Vegetariano'), 
                selected: _vegetariano, 
                onSelected: (v) => setState(() => _vegetariano = v),
                selectedColor: Colors.deepOrange.withValues(alpha: 0.2),
                checkmarkColor: Colors.deepOrange,
              ),
              FilterChip(
                label: const Text('Apimentado'), 
                selected: _apimentado, 
                onSelected: (v) => setState(() => _apimentado = v),
                selectedColor: Colors.deepOrange.withValues(alpha: 0.2),
                checkmarkColor: Colors.deepOrange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ingredientesController,
            decoration: const InputDecoration(labelText: 'Ingredientes', prefixIcon: Icon(Icons.food_bank_outlined), border: OutlineInputBorder()),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStockAndPrepCard(BuildContext context) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, icon: Icons.inventory_outlined, title: 'Estoque e Preparo'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _tempoPreparoController,
                  decoration: const InputDecoration(labelText: 'Tempo de preparo (min)', prefixIcon: Icon(Icons.timer_outlined), border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _ordemController,
                  decoration: const InputDecoration(labelText: 'Ordem', prefixIcon: Icon(Icons.sort), border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _estoqueController,
            decoration: const InputDecoration(labelText: 'Estoque', prefixIcon: Icon(Icons.inventory_outlined), border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Removido elevation e border side para um visual mais limpo
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) {
      debugPrint('⚠️ [UI] Formulário inválido. Verifique os campos obrigatórios.');
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      debugPrint('❌ [AUTH] Sessão expirada ao tentar salvar produto.');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sessão expirada.')));
      return;
    }

    debugPrint('💾 [CARDAPIO] Iniciando salvamento do produto...');
    final preco = double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0;
    final precoPromo = _precoPromocionalController.text.isNotEmpty 
        ? double.tryParse(_precoPromocionalController.text.replaceAll(',', '.')) 
        : null;

    final data = {
      'id': widget.produto?.id,
      'subcategoria_id': _subcategoriaId,
      'categoria_id': _categoriaId,
      'tipo': 'simples',
      'nome': _nomeController.text,
      'descricao': _descricaoController.text,
      'preco': preco,
      'preco_promocional': precoPromo,
      'imagem': _imagemController.text,
      'contem_gluten': _contemGluten ? 1 : 0,
      'contem_lactose': _contemLactose ? 1 : 0,
      'vegano': _vegano ? 1 : 0,
      'vegetariano': _vegetariano ? 1 : 0,
      'apimentado': _apimentado ? 1 : 0,
      'ingredientes_texto': _ingredientesController.text,
      'tempo_preparo_min': int.tryParse(_tempoPreparoController.text),
      'disponivel': _disponivel ? 1 : 0,
      'estoque': int.tryParse(_estoqueController.text),
      'ordem': int.tryParse(_ordemController.text) ?? 0,
      'ativo': _ativo ? 1 : 0,
      'destaque': _destaque ? 1 : 0,
      'criado_em': widget.produto?.criadoEm ?? DateTime.now().toIso8601String(),
      'atualizado_em': DateTime.now().toIso8601String(),
    };

    final success = await context.read<CardapioCubit>().saveProduto(data, id: widget.produto?.id);
    
    if (success && mounted) {
      // Listener handles navigation
    }
  }
}
