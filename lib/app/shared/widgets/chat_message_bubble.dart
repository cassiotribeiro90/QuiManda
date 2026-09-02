import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../modules/chat/models/chat_mensagem_model.dart';
import '../utils/image_helper.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMensagemModel message;
  final bool isMe;
  final String? lojaNome; // Nome da loja

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.lojaNome,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 DEFINE A INICIAL CORRETA PARA CADA AVATAR
    String inicialAvatar;

    if (isMe) {
      // 🔥 Mensagem do LOJISTA → usa a INICIAL DA LOJA
      inicialAvatar = _getInicialLoja();
    } else {
      // 🔥 Mensagem do CLIENTE → usa a INICIAL DO CLIENTE
      inicialAvatar = _getInicialCliente();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 🔥 AVATAR DO REMETENTE (para mensagens de outros - CLIENTE)
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              child: Text(
                inicialAvatar,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // 🔥 BALÃO DE MENSAGEM
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.chatPrimary.withValues(alpha: 0.85)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : Radius.circular(4),
                  bottomRight: isMe ? Radius.circular(4) : const Radius.circular(16),
                ),
                boxShadow: isMe
                    ? null
                    : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(context),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        message.dataFormatada,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : Colors.grey.shade500,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isLida ? Icons.done_all : Icons.done,
                          size: 12,
                          color: message.isLida ? Colors.white : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 🔥 AVATAR DO REMETENTE (para mensagens do "eu" - LOJISTA)
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.chatPrimary.withValues(alpha: 0.2),
              child: Text(
                inicialAvatar,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.chatPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 🔥 Retorna a inicial da LOJA (para mensagens do lojista)
  String _getInicialLoja() {
    // 1️⃣ PRIORIDADE: Usa o nome da loja
    if (lojaNome != null && lojaNome!.isNotEmpty) {
      return lojaNome!.substring(0, 1).toUpperCase();
    }

    // 2️⃣ FALLBACK: Usa "L" de Lojista
    return 'L';
  }

  /// 🔥 Retorna a inicial do CLIENTE (para mensagens do cliente)
  String _getInicialCliente() {
    // 1️⃣ PRIORIDADE: Usa o nome do remetente
    if (message.remetenteNome != null && message.remetenteNome!.isNotEmpty) {
      return message.remetenteNome!.substring(0, 1).toUpperCase();
    }

    // 2️⃣ FALLBACK: Usa "C" de Cliente
    return 'C';
  }

  Widget _buildMessageContent(BuildContext context) {
    if (message.isSistema) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message.mensagem,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.blue,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    if (message.isImagem) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.anexoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                ImageHelper.getFullImageUrl(message.anexoUrl),
                height: 150,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  width: 200,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          if (message.mensagem.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                message.mensagem,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
            ),
        ],
      );
    }

    return Text(
      message.mensagem,
      style: TextStyle(
        color: isMe ? Colors.white : Colors.black87,
        fontSize: 14,
      ),
    );
  }
}