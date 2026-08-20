import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../core/responsive/responsive_scaffold.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../home/views/home_view.dart';
import '../bloc/configuracoes_cubit.dart';
import '../bloc/configuracoes_state.dart';
import '../models/loja_model.dart';

class ConfiguracoesLojaPage extends StatefulWidget {
  const ConfiguracoesLojaPage({super.key});

  @override
  State<ConfiguracoesLojaPage> createState() => _ConfiguracoesLojaPageState();
}

class _ConfiguracoesLojaPageState extends State<ConfiguracoesLojaPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;
  late TextEditingController _instagramController;

  // Mask
  final _whatsappMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: { "#": RegExp(r'[0-9]') },
  );

  Color _corTema = Colors.blue;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _descricaoController = TextEditingController();
    _whatsappController = TextEditingController();
    _emailController = TextEditingController();
    _instagramController = TextEditingController();
    
    context.read<ConfiguracoesCubit>().carregarLoja();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  void _preencherFormulario(LojaModel loja) {
    _nomeController.text = loja.nome;
    _descricaoController.text = loja.descricao ?? '';
    _whatsappController.text = _whatsappMask.maskText(loja.whatsapp ?? '');
    _emailController.text = loja.email ?? '';
    _instagramController.text = loja.instagram ?? '';
    
    if (loja.corTema != null && loja.corTema!.isNotEmpty) {
      try {
        final hexColor = loja.corTema!.replaceFirst('#', '0xFF');
        _corTema = Color(int.parse(hexColor));
      } catch (_) {
        _corTema = Colors.blue;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConfiguracoesCubit, ConfiguracoesState>(
      listener: (context, state) {
        if (state is ConfiguracoesSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message), 
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ConfiguracoesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message), 
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ConfiguracoesLoaded && !_isDataLoaded) {
          _preencherFormulario(state.loja);
          _isDataLoaded = true;
        }
      },
      builder: (context, state) {
        final isLoading = state is ConfiguracoesLoading && !_isDataLoaded;
        final isSaving = state is ConfiguracoesSaving;

        if (isLoading) {
          return ResponsiveScaffold(
            appBar: AppBar(
              title: const Text('Configurações', style: TextStyle(color: Colors.white)),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              leading: MediaQuery.of(context).size.width < 900
                  ? IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => HomeView.scaffoldKey.currentState?.openDrawer(),
                    )
                  : null,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ConfiguracoesError && !_isDataLoaded) {
          return ResponsiveScaffold(
            appBar: AppBar(
              title: const Text('Configurações', style: TextStyle(color: Colors.white)),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              leading: MediaQuery.of(context).size.width < 900
                  ? IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => HomeView.scaffoldKey.currentState?.openDrawer(),
                    )
                  : null,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Erro ao carregar dados', style: AppTextStyles.titleSmall),
                  const SizedBox(height: 8),
                  Text(state.message, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.read<ConfiguracoesCubit>().carregarLoja(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        LojaModel? loja;
        if (state is ConfiguracoesLoaded) {
          loja = state.loja;
        } else if (state is ConfiguracoesSuccess) {
          loja = state.loja;
        }

        return ResponsiveScaffold(
          maxWidth: 800,
          appBar: AppBar(
            title: const Text('Configurações da Loja', style: TextStyle(color: Colors.white)),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            leading: MediaQuery.of(context).size.width < 900
                ? IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => HomeView.scaffoldKey.currentState?.openDrawer(),
                  )
                : null,
            actions: [
              if (!isSaving && loja != null)
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () => _salvar(loja!),
                  tooltip: 'Salvar',
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nome
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Loja *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.store),
                      ),
                      style: AppTextStyles.bodyLarge,
                      validator: (v) => v!.trim().isEmpty ? 'Digite o nome da loja' : null,
                    ),
                    const SizedBox(height: 16),

                    // Descrição
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // Cor do Tema
                    Row(
                      children: [
                        const Text('Cor do Tema', style: AppTextStyles.bodyLarge),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: _selecionarCor,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _corTema,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(Icons.color_lens, color: Colors.white, size: 20),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '#${_corTema.value.toRadixString(16).substring(2).toUpperCase()}',
                          style: TextStyle(color: Colors.grey.shade600, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // WhatsApp
                    TextFormField(
                      controller: _whatsappController,
                      inputFormatters: [_whatsappMask],
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp (com DDD)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.chat),
                        hintText: '(11) 99999-9999',
                      ),
                      keyboardType: TextInputType.phone,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.bodyMedium,
                      validator: (v) {
                        if (v != null && v.trim().isNotEmpty) {
                          final regex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!regex.hasMatch(v)) return 'E-mail inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Instagram
                    TextFormField(
                      controller: _instagramController,
                      decoration: const InputDecoration(
                        labelText: 'Instagram',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.camera_alt),
                        hintText: '@usuario',
                      ),
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 40),

                    ElevatedButton.icon(
                      onPressed: (isSaving || loja == null) ? null : () => _salvar(loja!),
                      icon: isSaving 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: Text(isSaving ? 'SALVANDO...' : 'SALVAR CONFIGURAÇÕES', style: AppTextStyles.button),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _selecionarCor() async {
    final Color? cor = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolha a cor do tema'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _corTema,
            onColorChanged: (c) => setState(() => _corTema = c),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _corTema),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (cor != null) {
      setState(() => _corTema = cor);
    }
  }

  void _salvar(LojaModel lojaAtual) {
    if (!_formKey.currentState!.validate()) return;

    final loja = LojaModel(
      id: lojaAtual.id,
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim().isEmpty ? null : _descricaoController.text.trim(),
      corTema: '#${_corTema.value.toRadixString(16).substring(2).toUpperCase()}',
      whatsapp: _whatsappController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      instagram: _instagramController.text.trim().isEmpty ? null : _instagramController.text.trim(),
    );

    context.read<ConfiguracoesCubit>().salvarLoja(loja);
  }
}
