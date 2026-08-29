import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';

import '../../../core/api_client.dart';
import '../../../models/chat_item.dart';
import '../../../models/filter_option.dart';
import '../models/chat_mensagem_model.dart';
import '../models/chat_model.dart';
import '../repositories/chat_repository.dart';
import 'chat_badge_cubit.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository = ChatRepository(GetIt.I<ApiClient>());
  static final Map<int, List<ChatMensagemModel>> _mensagensCache = {};

  ChatBloc() : super(ChatState.initial()) {
    // 🔥 Lojista (Padrão QuiGestor)
    on<ChatLoadChats>(_onLoadChats);
    on<ChatLoadMore>(_onLoadMore);
    on<ChatRefresh>(_onRefresh);
    on<ChatFiltersApplied>(_onFiltersApplied);
    on<ChatUpdateNaoLidas>(_onUpdateNaoLidas);
    
    // 🔥 Sincronização e Legado
    on<NovaMensagemRecebida>(_onNovaMensagemRecebida);
    on<LimparChat>(_onLimparChat);
    on<CarregarMensagensLojista>(_onCarregarMensagensLojista);
    on<EnviarMensagemLojista>(_onEnviarMensagemLojista);
    on<MarcarMensagensComoLidasLojista>(_onMarcarMensagensComoLidasLojista);
  }

  Future<void> _onLoadChats(ChatLoadChats event, Emitter<ChatState> emit) async {
    // 🔥 Evita recarregar se já estiver carregando (proteção extra)
    if (state.isLoading && !event.reset) return;

    if (event.reset) {
      emit(state.copyWith(
        items: [],
        page: 1,
        hasMore: true,
        hasLoaded: false,
        isLoading: true,
        clearError: true,
      ));
    } else if (!state.hasLoaded) {
      emit(state.copyWith(isLoading: true));
    }

    try {
      final response = await _repository.getChatsLojista(
        page: state.page,
        perPage: 20,
        filters: state.currentFilters,
      );

      final updatedItems = event.reset ? response.items : [...state.items, ...response.items];

      emit(state.copyWith(
        items: updatedItems,
        total: response.pagination.total,
        page: response.pagination.page + 1,
        hasMore: updatedItems.length < response.pagination.total,
        hasLoaded: true,
        isLoading: false,
        isLoadingMore: false,
        filterGroups: response.filterGroups ?? state.filterGroups,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
        isLoadingMore: false,
      ));
    }
  }

  void _onLoadMore(ChatLoadMore event, Emitter<ChatState> emit) {
    if (state.hasMore && !state.isLoadingMore && state.hasLoaded) {
      emit(state.copyWith(isLoadingMore: true));
      add(const ChatLoadChats(reset: false));
    }
  }

  Future<void> _onRefresh(ChatRefresh event, Emitter<ChatState> emit) async {
    add(const ChatLoadChats(reset: true));
  }

  void _onFiltersApplied(ChatFiltersApplied event, Emitter<ChatState> emit) {
    // 🔥 Evita recarregar se os filtros forem exatamente iguais
    if (const MapEquality().equals(event.params, state.currentFilters)) {
      return;
    }

    emit(state.copyWith(
      currentFilters: event.params,
      items: [],
      page: 1,
      hasMore: true,
      hasLoaded: false,
      isLoading: true,
      clearError: true,
    ));
    add(const ChatLoadChats(reset: true));
  }

  Future<void> _onUpdateNaoLidas(ChatUpdateNaoLidas event, Emitter<ChatState> emit) async {
    try {
      final total = await _repository.contarNaoLidasLojista();
      GetIt.I<ChatBadgeCubit>().setBadge(total);
    } catch (_) {}
  }

  Future<void> _onCarregarMensagensLojista(CarregarMensagensLojista event, Emitter<ChatState> emit) async {
    if (_mensagensCache.containsKey(event.chatId)) {
      emit(state.copyWith(mensagensAtuais: _mensagensCache[event.chatId], chatIdAtivo: event.chatId));
    } else {
      emit(state.copyWith(isLoading: true));
    }

    try {
      final mensagens = await _repository.getMensagensLojista(event.chatId);
      _mensagensCache[event.chatId] = mensagens;
      emit(state.copyWith(mensagensAtuais: mensagens, chatIdAtivo: event.chatId, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onEnviarMensagemLojista(EnviarMensagemLojista event, Emitter<ChatState> emit) async {
    try {
      final mensagem = await _repository.enviarMensagemLojista(
        event.chatId,
        {
          'mensagem': event.mensagem,
          'tipo': event.tipo,
          'anexo_url': event.anexoUrl,
          'pedido_id': event.pedidoId,
        },
      );

      if (_mensagensCache.containsKey(event.chatId)) {
        _mensagensCache[event.chatId]!.add(mensagem);
      } else {
        _mensagensCache[event.chatId] = [mensagem];
      }

      emit(state.copyWith(
        mensagensAtuais: List.from(_mensagensCache[event.chatId]!),
        mensagemEnviada: mensagem,
      ));

      add(const ChatLoadChats(reset: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onMarcarMensagensComoLidasLojista(MarcarMensagensComoLidasLojista event, Emitter<ChatState> emit) async {
    try {
      await _repository.marcarMensagensComoLidasLojista(event.chatId);
      add(const ChatUpdateNaoLidas());
      add(const ChatLoadChats(reset: true));
    } catch (_) {}
  }

  Future<void> _onNovaMensagemRecebida(NovaMensagemRecebida event, Emitter<ChatState> emit) async {
    if (state.chatIdAtivo == event.mensagem.chatId) {
      if (_mensagensCache.containsKey(event.mensagem.chatId)) {
        _mensagensCache[event.mensagem.chatId]!.add(event.mensagem);
      } else {
        _mensagensCache[event.mensagem.chatId] = [event.mensagem];
      }
      emit(state.copyWith(mensagensAtuais: List.from(_mensagensCache[event.mensagem.chatId]!)));
    } else {
      if (_mensagensCache.containsKey(event.mensagem.chatId)) {
        _mensagensCache[event.mensagem.chatId]!.add(event.mensagem);
      }
    }
    add(const ChatUpdateNaoLidas());
    add(const ChatLoadChats(reset: true));
  }

  void _onLimparChat(LimparChat event, Emitter<ChatState> emit) {
    emit(ChatState.initial());
  }

  static void limparCache(int chatId) {
    _mensagensCache.remove(chatId);
  }
}
