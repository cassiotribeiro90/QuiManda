import 'package:flutter_bloc/flutter_bloc.dart';
import 'configuracoes_state.dart';
import '../models/loja_model.dart';
import '../services/loja_service.dart';

class ConfiguracoesCubit extends Cubit<ConfiguracoesState> {
  final LojaService _service;

  ConfiguracoesCubit(this._service) : super(ConfiguracoesInitial());

  Future<void> carregarLoja() async {
    emit(ConfiguracoesLoading());
    try {
      final loja = await _service.getLoja();
      emit(ConfiguracoesLoaded(loja));
    } catch (e) {
      emit(ConfiguracoesError(e.toString()));
    }
  }

  Future<void> salvarLoja(LojaModel loja) async {
    emit(ConfiguracoesSaving());
    try {
      final atualizada = await _service.updateLoja(loja);
      emit(ConfiguracoesSuccess('Configurações salvas com sucesso!', atualizada));
      emit(ConfiguracoesLoaded(atualizada));
    } catch (e) {
      emit(ConfiguracoesError(e.toString()));
    }
  }
}
