part of 'chat_bloc.dart';

/// 🔥 Eventos do Chat
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

// ================================================================
// 🔥 EVENTOS DO CLIENTE
// ================================================================

/// Carregar lista de chats do cliente
class CarregarChats extends ChatEvent {
  const CarregarChats();
}

/// Iniciar chat com a loja (obter ou criar)
class IniciarChatComLoja extends ChatEvent {
  final int? lojaId; // 🔥 OPCIONAL (para chat genérico)
  final int? pedidoId; // 🔥 OPCIONAL (para chat com pedido)
  final String? mensagemInicial;

  const IniciarChatComLoja({
    this.lojaId,
    this.pedidoId,
    this.mensagemInicial,
  }) : assert(lojaId != null || pedidoId != null,
            'lojaId ou pedidoId deve ser informado');

  @override
  List<Object?> get props => [lojaId, pedidoId, mensagemInicial];
}

/// Carregar mensagens de um chat específico
class CarregarMensagens extends ChatEvent {
  final int chatId;
  const CarregarMensagens(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Criar um novo chat
class CriarChat extends ChatEvent {
  final Map<String, dynamic> data;
  const CriarChat(this.data);

  @override
  List<Object?> get props => [data];
}

/// Enviar mensagem em um chat
class EnviarMensagem extends ChatEvent {
  final int chatId;
  final int? pedidoId; // 🔥 OPCIONAL
  final String mensagem;
  final String tipo;
  final String? anexoUrl;

  const EnviarMensagem({
    required this.chatId,
    this.pedidoId,
    required this.mensagem,
    this.tipo = 'texto',
    this.anexoUrl,
  });

  @override
  List<Object?> get props => [chatId, pedidoId, mensagem, tipo, anexoUrl];
}

/// Marcar mensagens como lidas
class MarcarMensagensComoLidas extends ChatEvent {
  final int chatId;
  const MarcarMensagensComoLidas(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Arquivar um chat
class ArquivarChat extends ChatEvent {
  final int chatId;
  const ArquivarChat(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Contar mensagens não lidas
class ContarNaoLidas extends ChatEvent {
  const ContarNaoLidas();
}

// ================================================================
// 🔥 EVENTOS DO LOJISTA (Padrão quiGestor)
// ================================================================

/// Carregar chats do lojista
class ChatLoadChats extends ChatEvent {
  final bool reset;
  const ChatLoadChats({this.reset = false});

  @override
  List<Object?> get props => [reset];
}

/// Carregar próxima página
class ChatLoadMore extends ChatEvent {
  const ChatLoadMore();
}

class ChatRefresh extends ChatEvent {
  const ChatRefresh();
}

class ChatFiltersApplied extends ChatEvent {
  final Map<String, dynamic> params;
  const ChatFiltersApplied(this.params);

  @override
  List<Object?> get props => [params];
}

/// Aplicar filtros
class ChatApplyFilters extends ChatEvent {
  final String? status;
  final String? periodo;
  final String? search;

  const ChatApplyFilters({this.status, this.periodo, this.search});

  @override
  List<Object?> get props => [status, periodo, search];
}

/// Limpar filtros
class ChatClearFilters extends ChatEvent {
  const ChatClearFilters();
}

/// Atualizar badge de não lidas
class ChatUpdateNaoLidas extends ChatEvent {
  const ChatUpdateNaoLidas();
}

/// Carregar mensagens de um chat (lojista)
class CarregarMensagensLojista extends ChatEvent {
  final int chatId;
  const CarregarMensagensLojista(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Enviar mensagem como lojista
class EnviarMensagemLojista extends ChatEvent {
  final int chatId;
  final int? pedidoId; // 🔥 OPCIONAL
  final String mensagem;
  final String tipo;
  final String? anexoUrl;

  const EnviarMensagemLojista({
    required this.chatId,
    this.pedidoId,
    required this.mensagem,
    this.tipo = 'texto',
    this.anexoUrl,
  });

  @override
  List<Object?> get props => [chatId, pedidoId, mensagem, tipo, anexoUrl];
}

/// Marcar mensagens como lidas (lojista)
class MarcarMensagensComoLidasLojista extends ChatEvent {
  final int chatId;
  const MarcarMensagensComoLidasLojista(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Atualizar status do chat (lojista)
class AtualizarStatusChat extends ChatEvent {
  final int chatId;
  final String status;
  const AtualizarStatusChat(this.chatId, this.status);

  @override
  List<Object?> get props => [chatId, status];
}

/// Contar mensagens não lidas (lojista)
class ContarNaoLidasLojista extends ChatEvent {
  const ContarNaoLidasLojista();
}

// ================================================================
// 🔥 EVENTOS DE SINCRONIZAÇÃO
// ================================================================

/// Atualizar chat com nova mensagem (recebida via push)
class NovaMensagemRecebida extends ChatEvent {
  final ChatMensagemModel mensagem;
  const NovaMensagemRecebida(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}

/// Limpar estado do chat
class LimparChat extends ChatEvent {
  const LimparChat();
}
