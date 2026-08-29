
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
      final response = await dio.get('/api/lojista/chats'); // ✅ adicionado /api

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
      final response = await dio.post('/api/lojista/chats', data: data); // ✅ /api

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

      final response = await dio.post('/api/lojista/chats', data: data); // ✅ /api

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
      final response = await dio.get('/api/lojista/chats/$id'); // ✅ /api

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
      final response = await dio.delete('/api/lojista/chats/$id'); // ✅ /api

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erro ao arquivar chat');
      }
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<int> contarNaoLidas() async {
    try {
      final response = await dio.get('/api/lojista/chats/nao-lidas'); // ✅ /api

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
      final response = await dio.get('/api/app/chats/$chatId/mensagens'); // ✅ /api (rota de cliente)

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
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

      final response = await dio.post(
        '/api/app/chats/$chatId/mensagem', // ✅ /api (rota de cliente)
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
      final response = await dio.put('/api/lojista/chats/$chatId/ler'); // ✅ /api

      if (response.data['success'] == true) {
        return response.data['data']['lidas'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ================================================================
  // 🔥 NOVOS MÉTODOS PARA LOJISTA (corrigidos e com /api)
  // ================================================================

  /// Obtém o ID do chat associado a um pedido específico (ou cria se não existir)
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

  Future<List<ChatModel>> getChatsLojista() async {
    try {
      final response = await dio.get('/api/lojista/chats'); // ✅ /api

      if (response.data['success'] == true) {
        final chatList = response.data['data'] as List;
        return chatList.map((item) => ChatModel.fromJson(item)).toList();
      }

      throw Exception(response.data['message'] ?? 'Erro ao carregar chats');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<List<ChatModel>> getChatsLojistaComNaoLidas() async {
    try {
      final response = await dio.get('/api/lojista/chats/com-nao-lidas'); // ✅ /api

      if (response.data['success'] == true) {
        final chatList = response.data['data'] as List;
        return chatList.map((item) => ChatModel.fromJson(item)).toList();
      }

      throw Exception(response.data['message'] ?? 'Erro ao carregar chats com não lidas');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<int> contarNaoLidasLojista() async {
    try {
      final response = await dio.get('/api/lojista/chats/nao-lidas'); // ✅ /api

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
      final response = await dio.get('/api/lojista/chats/$chatId/mensagens'); // ✅ /api

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
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
        '/api/lojista/chats/$chatId/mensagem', // ✅ /api
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
      final response = await dio.put('/api/lojista/chats/$chatId/ler'); // ✅ /api

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
        '/api/lojista/chats/$chatId/status', // ✅ /api
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