
import 'package:flutter/cupertino.dart';
import '../../../models/chat_item.dart';
import '../../../models/filter_option.dart';
import '../models/chat_mensagem_model.dart';
import '../models/chat_model.dart';
import 'base_repository.dart';

class ChatRepository extends BaseRepository {
  ChatRepository(super.apiClient);

  // ================================================================
  // 🔥 CHATS DO CLIENTE (mantido)
  // ================================================================

  Future<List<ChatModel>> getMeusChats() async {
    try {
      final response = await dio.get('/api/lojista/chats');

      if (response.data['success'] == true) {
        final chatList = response.data['data'] as List;
        return chatList.map((item) => ChatModel.fromJson(item)).toList();
      }

      throw Exception(response.data['message'] ?? 'Erro ao carregar chats');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<ChatModel> criarChat(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/api/lojista/chats', data: data);

      if (response.data['success'] == true) {
        return ChatModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Erro ao criar chat');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Map<String, dynamic>> iniciarChatComLoja({
    int? lojaId,
    int? pedidoId,
    String? mensagemInicial,
  }) async {
    if (lojaId == null && pedidoId == null) {
      throw Exception('lojaId ou pedidoId é obrigatório');
    }

    try {
      final Map<String, dynamic> data = {};
      if (lojaId != null) data['loja_id'] = lojaId;
      if (pedidoId != null) data['pedido_id'] = pedidoId;

      final response = await dio.post('/api/lojista/chats', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true) {
          final result = response.data['data'];

          final chat = ChatModel.fromJson(result['chat']);
          final mensagens = (result['mensagens'] as List)
              .map((item) => ChatMensagemModel.fromJson(item))
              .toList();

          return {
            'chat': chat,
            'mensagens': mensagens,
          };
        }
      }

      throw Exception(response.data['message'] ?? 'Erro ao iniciar chat');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<ChatModel> getChat(int id) async {
    try {
      final response = await dio.get('/api/lojista/chats/$id');

      if (response.data['success'] == true) {
        return ChatModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Erro ao carregar chat');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> arquivarChat(int id) async {
    try {
      final response = await dio.delete('/api/lojista/chats/$id');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erro ao arquivar chat');
      }
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<int> contarNaoLidas() async {
    try {
      final response = await dio.get('/api/lojista/chats/nao-lidas');

      if (response.data['success'] == true) {
        return response.data['data']['total_nao_lidas'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ================================================================
  // 🔥 MENSAGENS (cliente)
  // ================================================================

  Future<List<ChatMensagemModel>> getMensagens(int chatId) async {
    try {
      debugPrint('📡 [ChatRepository] getMensagens (cliente fallback): /api/lojista/chats/$chatId/mensagens');
      final response = await dio.get('/api/lojista/chats/$chatId/mensagens'); 

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        debugPrint('📥 [ChatRepository] getMensagens retornou ${data.length} mensagens');
        return data.map((item) => ChatMensagemModel.fromJson(item)).toList();
      }

      throw Exception(response.data['message'] ?? 'Erro ao carregar mensagens');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<ChatMensagemModel> enviarMensagem(int chatId, Map<String, dynamic> data) async {
    try {
      final Map<String, dynamic> payload = {
        'mensagem': data['mensagem'] ?? '',
        'tipo': data['tipo'] ?? 'texto',
        'pedido_id': data['pedido_id'],
      };

      if (data['anexo_url'] != null && data['anexo_url'].toString().isNotEmpty) {
        payload['anexo_url'] = data['anexo_url'];
      }

      debugPrint('📡 [ChatRepository] enviarMensagem (cliente fallback): /api/lojista/chats/$chatId/mensagem');
      final response = await dio.post(
        '/api/lojista/chats/$chatId/mensagem', 
        data: payload,
      );

      if (response.data['success'] == true) {
        return ChatMensagemModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Erro ao enviar mensagem');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<int> marcarMensagensComoLidas(int chatId) async {
    try {
      final response = await dio.put('/api/lojista/chats/$chatId/ler');

      if (response.data['success'] == true) {
        return response.data['data']['lidas'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ================================================================
  // 🔥 NOVOS MÉTODOS PARA LOJISTA (Padrão QuiGestor)
  // ================================================================

  Future<int> getChatIdByPedido(int pedidoId) async {
    try {
      final response = await dio.get(
        '/api/lojista/chats/por-pedido/$pedidoId',
      );

      if (response.data['success'] == true) {
        return response.data['data']['chat_id'] as int;
      }

      throw Exception(response.data['message'] ?? 'Erro ao obter chat do pedido');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<ChatResponse> getChatsLojista({
    int page = 1,
    int perPage = 20,
    Map<String, dynamic> filters = const {},
  }) async {
    try {
      final params = {
        'page': page,
        'per_page': perPage,
        ...filters,
      };
      
      // 🔥 Log da URL completa para depuração
      final baseUrl = dio.options.baseUrl;
      final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
      debugPrint('🔗 [ChatRepository] URL final: $baseUrl/api/lojista/chats?$queryString');
      
      final response = await dio.get('/api/lojista/chats', queryParameters: params);

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final items = (data['items'] as List?)
                ?.map((e) => ChatItem.fromJson(e))
                .toList() ??
            [];
        final pagination = data['pagination'];
        final filterOptions = data['filter_options'] as Map<String, dynamic>?;
        final filterGroups = _parseFilterGroups(filterOptions);

        return ChatResponse(
          items: items,
          pagination: Pagination.fromJson(pagination),
          filterGroups: filterGroups,
        );
      }

      throw Exception(response.data['message'] ?? 'Erro ao carregar chats');
    } catch (e) {
      throw handleError(e);
    }
  }

  List<FilterGroup>? _parseFilterGroups(Map<String, dynamic>? filterOptions) {
    if (filterOptions == null) return null;
    return filterOptions.entries.map((entry) {
      return FilterGroup.fromJson(entry.key, entry.value);
    }).toList();
  }

  Future<int> contarNaoLidasLojista() async {
    try {
      final response = await dio.get('/api/lojista/chats/nao-lidas');

      if (response.data['success'] == true) {
        return response.data['data']['total_nao_lidas'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<ChatMensagemModel>> getMensagensLojista(int chatId) async {
    try {
      debugPrint('📡 [ChatRepository] getMensagensLojista: /api/lojista/chats/$chatId/mensagens');
      final response = await dio.get('/api/lojista/chats/$chatId/mensagens');

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        debugPrint('📥 [ChatRepository] getMensagensLojista retornou ${data.length} mensagens');
        return data.map((item) => ChatMensagemModel.fromJson(item)).toList();
      }

      throw Exception(response.data['message'] ?? 'Erro ao carregar mensagens');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<ChatMensagemModel> enviarMensagemLojista(int chatId, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        '/api/lojista/chats/$chatId/mensagem',
        data: data,
      );

      if (response.data['success'] == true) {
        return ChatMensagemModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Erro ao enviar mensagem');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<int> marcarMensagensComoLidasLojista(int chatId) async {
    try {
      final response = await dio.put('/api/lojista/chats/$chatId/ler');

      if (response.data['success'] == true) {
        return response.data['data']['lidas'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<ChatModel> atualizarStatusChatLojista(int chatId, String status) async {
    try {
      final response = await dio.put(
        '/api/lojista/chats/$chatId/status',
        data: {'status': status},
      );

      if (response.data['success'] == true) {
        return ChatModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Erro ao atualizar status do chat');
    } catch (e) {
      throw handleError(e);
    }
  }
}

class ChatResponse {
  final List<ChatItem> items;
  final Pagination pagination;
  final List<FilterGroup>? filterGroups;

  ChatResponse({
    required this.items,
    required this.pagination,
    this.filterGroups,
  });
}

class Pagination {
  final int total;
  final int page;
  final int perPage;
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      totalPages: json['total_pages'] ?? 0,
    );
  }
}
