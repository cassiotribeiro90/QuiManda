import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/produto_model.dart';
import '../../bloc/cardapio_cubit.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProdutoCard extends StatelessWidget {
  final ProdutoModel produto;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(bool) onToggle;

  const ProdutoCard({
    super.key,
    required this.produto,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem do produto
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: produto.imagemUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: produto.imagemUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: const Icon(Icons.restaurant, color: Colors.grey)),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.restaurant, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 16),
                // Informações
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(produto.nome, style: AppTextStyles.titleSmall),
                      if (produto.descricao != null)
                        Text(
                          produto.descricao!,
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(produto.precoFormatado, style: AppTextStyles.price.copyWith(fontSize: 17)),
                          const SizedBox(width: 12),
                          _buildEstoqueBadge(),
                        ],
                      ),
                    ],
                  ),
                ),
                // Toggle Disponibilidade
                Switch(
                  value: produto.disponivel,
                  onChanged: onToggle,
                  activeThumbColor: Colors.green,
                ),
              ],
            ),
          ),

          // Botões de Ação
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _abrirDialogoEstoque(context),
                  icon: const Icon(Icons.inventory_2_outlined, size: 18),
                  label: const Text('ESTOQUE', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: Colors.blueGrey),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('EDITAR', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('EXCLUIR', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstoqueBadge() {
    Color color = Colors.green;
    String text = 'Disponível';

    if (produto.estoque == null) {
      text = 'Ilimitado';
      color = Colors.blue;
    } else if (produto.estoque == 0) {
      text = 'Esgotado';
      color = Colors.red;
    } else if (produto.estoque! <= 5) {
      text = 'Apenas ${produto.estoque}';
      color = Colors.orange;
    } else {
      text = '${produto.estoque} em estoque';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  void _abrirDialogoEstoque(BuildContext context) {
    final controller = TextEditingController(text: produto.estoque?.toString() ?? '');
    bool isIlimitado = produto.estoque == null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Atualizar Estoque'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text('Estoque ilimitado'),
                value: isIlimitado,
                onChanged: (val) {
                  setState(() {
                    isIlimitado = val ?? false;
                    if (isIlimitado) controller.clear();
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              if (!isIlimitado)
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade disponível',
                    border: OutlineInputBorder(),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: () {
                final qtd = isIlimitado ? null : int.tryParse(controller.text);
                context.read<CardapioCubit>().atualizarEstoque(produto.id!, qtd);
                Navigator.pop(context);
              },
              child: const Text('SALVAR'),
            ),
          ],
        ),
      ),
    );
  }
}
