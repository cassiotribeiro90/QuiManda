// lib/app/modules/avaliacoes/services/avaliacao_service.dart

import '../../../core/api_client.dart';
import '../../../models/filter_option.dart';
import '../models/avaliacao_model.dart';

class AvaliacaoService {
  final ApiClient _apiClient;
  AvaliacaoService(this._apiClient);

  Future<AvaliacoesResponse> getAvaliacoes({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get(
      '/api/lojista/avaliacoes',
      queryParams: {
        if (status != null && status != 'todos') 'status': status,
        'page': page,
        'per_page': perPage,
      },
    );

    final data = response.data['data'];
    final items = (data['items'] as List)
        .map((e) => AvaliacaoModel.fromJson(e))
        .toList();

    // Processa filter_options
    List<FilterGroup> filterGroups = [];
    if (data['filter_options'] != null) {
      final options = data['filter_options'] as Map<String, dynamic>;
      options.forEach((key, value) {
        if (value is List) {
          filterGroups.add(FilterGroup.fromJson(key, value));
        }
      });
    }

    final total = (data['pagination']['total'] as num?)?.toInt() ?? 0;
    final hasMore = page < (data['pagination']['total_pages'] as num?)!.toInt();

    return AvaliacoesResponse(
      avaliacoes: items,
      filterGroups: filterGroups,
      total: total,
      hasMore: hasMore,
    );
  }

  Future<void> atualizarStatus(int id, String status) async {
    await _apiClient.put(
      '/api/lojista/avaliacoes/$id/status',
      data: {'status': status},
    );
  }

  Future<void> responder(int id, String resposta) async {
    await _apiClient.post(
      '/api/lojista/avaliacoes/$id/responder',
      data: {'resposta': resposta},
    );
  }
}

class AvaliacoesResponse {
  final List<AvaliacaoModel> avaliacoes;
  final List<FilterGroup> filterGroups;
  final int total;
  final bool hasMore;

  AvaliacoesResponse({
    required this.avaliacoes,
    required this.filterGroups,
    required this.total,
    required this.hasMore,
  });
}