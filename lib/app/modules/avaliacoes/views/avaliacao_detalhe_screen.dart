// lib/app/modules/avaliacoes/views/avaliacao_detalhe_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/responsive/responsive_scaffold.dart';
import '../../../widgets/custom_app_bar.dart';
import '../bloc/avaliacoes_cubit.dart';
import '../models/avaliacao_model.dart';


class AvaliacaoDetalheScreen extends StatefulWidget {
  final AvaliacaoModel avaliacao;
  const AvaliacaoDetalheScreen({super.key, required this.avaliacao});

  @override
  State<AvaliacaoDetalheScreen> createState() => _AvaliacaoDetalheScreenState();
}

class _AvaliacaoDetalheScreenState extends State<AvaliacaoDetalheScreen> {
  late final TextEditingController _respostaController;

  @override
  void initState() {
    super.initState();
    // Preenche com a resposta existente (se houver) para edição
    _respostaController = TextEditingController(
      text: widget.avaliacao.resposta ?? '',
    );
  }

  @override
  void dispose() {
    _respostaController.dispose();
    super.dispose();
  }

  Future<void> _salvarResposta() async {
    final resposta = _respostaController.text.trim();
    if (resposta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escreva uma resposta')),
      );
      return;
    }

    final cubit = context.read<AvaliacoesCubit>();
    await cubit.responder(widget.avaliacao.id, resposta);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resposta salva com sucesso')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AvaliacoesCubit>();
    final avaliacao = widget.avaliacao;
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      appBar: CustomAppBar(
        title: 'Detalhe da Avaliação',
        automaticallyImplyLeading: true,
      ),
      body: Align(
        // 🔥 Garante que o conteúdo fique no TOPO, mesmo se o corpo for curto
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ============ CARD PRINCIPAL ============
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            avaliacao.estrelas,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(width: 12),
                          Chip(
                            label: Text(avaliacao.statusLabel),
                            backgroundColor: _getStatusColor(avaliacao.status)
                                .withValues(alpha: 0.15),
                            side: BorderSide(
                              color: _getStatusColor(avaliacao.status),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.event, 'Data', avaliacao.dataFormatada),
                      if (avaliacao.pedidoId != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.receipt_long,
                          'Pedido',
                          '#${avaliacao.pedidoId}',
                        ),
                      ],
                      if (avaliacao.produtoNome != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.restaurant_menu,
                          'Produto',
                          avaliacao.produtoNome!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ============ COMENTÁRIO DO CLIENTE ============
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comentário do Cliente',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        avaliacao.comentario?.isNotEmpty == true
                            ? avaliacao.comentario!
                            : 'Sem comentário',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ============ RESPOSTA (EDITÁVEL) ============
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        avaliacao.hasResposta
                            ? 'Editar Resposta'
                            : 'Responder',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _respostaController,
                        maxLines: 4,
                        minLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Escreva sua resposta...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _salvarResposta,
                        icon: const Icon(Icons.send),
                        label: Text(
                          avaliacao.hasResposta
                              ? 'Salvar Alterações'
                              : 'Enviar Resposta',
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ============ AÇÕES DE APROVAÇÃO/REJEIÇÃO ============
              Row(
                children: [
                  if (!avaliacao.isAprovado)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await cubit.aprovar(avaliacao.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Avaliação aprovada')),
                            );
                            context.pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Aprovar'),
                      ),
                    ),
                  if (!avaliacao.isAprovado && !avaliacao.isRejeitado)
                    const SizedBox(width: 8),
                  if (!avaliacao.isRejeitado)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await cubit.rejeitar(avaliacao.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Avaliação rejeitada')),
                            );
                            context.pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Rejeitar'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'aprovado':
        return Colors.green;
      case 'rejeitado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}