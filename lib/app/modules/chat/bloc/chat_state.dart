part of 'chat_bloc.dart';

/// 🔥 Estados do Chat (Refatorado para Padrão QuiGestor)
class ChatState extends Equatable {
  final List<ChatItem> items;
  final int page;
  final int total;
  final bool hasMore;
  final bool hasLoaded;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final List<FilterGroup>? filterGroups;
  final Map<String, dynamic> currentFilters;

  // Estados específicos para ações
  final ChatModel? chatCriado;
  final ChatMensagemModel? mensagemEnviada;
  final List<ChatMensagemModel>? mensagensAtuais;
  final int? chatIdAtivo;

  const ChatState({
    this.items = const [],
    this.page = 1,
    this.total = 0,
    this.hasMore = true,
    this.hasLoaded = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.filterGroups,
    this.currentFilters = const {},
    this.chatCriado,
    this.mensagemEnviada,
    this.mensagensAtuais,
    this.chatIdAtivo,
  });

  factory ChatState.initial() => const ChatState();

  ChatState copyWith({
    List<ChatItem>? items,
    int? page,
    int? total,
    bool? hasMore,
    bool? hasLoaded,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    List<FilterGroup>? filterGroups,
    Map<String, dynamic>? currentFilters,
    ChatModel? chatCriado,
    ChatMensagemModel? mensagemEnviada,
    List<ChatMensagemModel>? mensagensAtuais,
    int? chatIdAtivo,
    bool clearError = false,
  }) {
    return ChatState(
      items: items ?? this.items,
      page: page ?? this.page,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      filterGroups: filterGroups ?? this.filterGroups,
      currentFilters: currentFilters ?? this.currentFilters,
      chatCriado: chatCriado ?? this.chatCriado,
      mensagemEnviada: mensagemEnviada ?? this.mensagemEnviada,
      mensagensAtuais: mensagensAtuais ?? this.mensagensAtuais,
      chatIdAtivo: chatIdAtivo ?? this.chatIdAtivo,
    );
  }

  @override
  List<Object?> get props => [
        items,
        page,
        total,
        hasMore,
        hasLoaded,
        isLoading,
        isLoadingMore,
        error,
        filterGroups,
        currentFilters,
        chatCriado,
        mensagemEnviada,
        mensagensAtuais,
        chatIdAtivo,
      ];
}

// 🔥 Classes legadas para compatibilidade (serão removidas gradualmente)
abstract class ChatLegacyState extends ChatState {}
class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {
  const ChatLoading() : super(isLoading: true);
}
class ChatError extends ChatState {
  final String message;
  ChatError({required this.message}) : super(error: message);
}
class ChatLoaded extends ChatState {
  final List<ChatModel> chats;
  final int totalNaoLidas;

  ChatLoaded({
    required this.chats,
    this.totalNaoLidas = 0,
  }) : super(
    items: chats.map((e) => ChatItem(
      id: e.id,
      clienteId: e.clienteId,
      clienteNome: e.clienteNome,
      ultimaMensagem: e.ultimaMensagem,
      dataUltimaMensagem: e.dataUltimaMensagem,
      status: e.status,
      naoLidas: e.naoLidas,
      pedidoId: e.pedidoId,
    )).toList(),
    hasLoaded: true,
  );
}
class ChatLojistaLoaded extends ChatState {
  ChatLojistaLoaded({
    required List<ChatModel> chats,
    int totalNaoLidas = 0,
    List<FilterGroup>? filterGroups,
    String? selectedPeriodo,
    String? selectedStatus,
    String searchQuery = '',
    int currentPage = 1,
    int totalPages = 1,
    int totalItems = 0,
  }) : super(
    items: chats.map((e) => ChatItem(
      id: e.id,
      clienteId: e.clienteId,
      clienteNome: e.clienteNome,
      ultimaMensagem: e.ultimaMensagem,
      dataUltimaMensagem: e.dataUltimaMensagem,
      status: e.status,
      naoLidas: e.naoLidas,
      pedidoId: e.pedidoId,
    )).toList(),
    page: currentPage,
    total: totalItems,
    hasLoaded: true,
    filterGroups: filterGroups,
    currentFilters: {
      if (selectedPeriodo != null) 'periodo': selectedPeriodo,
      if (selectedStatus != null) 'status': selectedStatus,
      if (searchQuery.isNotEmpty) 'search': searchQuery,
    },
  );

  String? get selectedPeriodo => currentFilters['periodo'];
  String? get selectedStatus => currentFilters['status'];
  String get searchQuery => currentFilters['search'] ?? '';
}

class ChatMessagesLoaded extends ChatState {
  final List<ChatMensagemModel> mensagens;
  final int chatId;
  const ChatMessagesLoaded({required this.mensagens, required this.chatId}) 
    : super(mensagensAtuais: mensagens, chatIdAtivo: chatId);
}
