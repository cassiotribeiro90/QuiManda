import 'package:flutter/material.dart';
import '../../../models/chat_item.dart';
import '../views/chat_screen.dart';

class ChatItemWidget extends StatelessWidget {
  final ChatItem chat;
  final VoidCallback? onTap;

  const ChatItemWidget({
    super.key,
    required this.chat,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: chat.naoLidas > 0 ? 2 : 0.5,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
          child: Text(
            chat.clienteNome?.isNotEmpty == true
                ? chat.clienteNome![0].toUpperCase()
                : '?',
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chat.clienteNome ?? 'Cliente',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: chat.naoLidas > 0 ? FontWeight.bold : FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              chat.dataUltimaMensagemFormatada,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  chat.ultimaMensagem ?? 'Nenhuma mensagem',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: chat.naoLidas > 0
                        ? (isDark ? Colors.white : Colors.black87)
                        : theme.textTheme.bodySmall?.color,
                    fontWeight: chat.naoLidas > 0 ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              if (chat.naoLidas > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${chat.naoLidas}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: chat.id,
                pedidoId: chat.pedidoId,
              ),
            ),
          ).then((_) {
            if (onTap != null) onTap!();
          });
        },
      ),
    );
  }
}
