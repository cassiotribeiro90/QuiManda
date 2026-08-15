import 'package:flutter_bloc/flutter_bloc.dart';
import 'loja_state.dart';
import '../service/loja_service.dart';
import '../model/loja_model.dart';

class LojaCubit extends Cubit<LojaState> {
  final LojaService _service;

  LojaCubit(this._service) : super(LojaInitial());

  Future<void> loadLoja() async {
    emit(LojaLoading());
    try {
      final loja = await _service.getLoja();
      emit(LojaLoaded(loja));
    } catch (e) {
      emit(LojaError('Falha ao carregar loja: ${e.toString()}'));
    }
  }

  Future<void> updateLoja(LojaModel loja) async {
    emit(LojaLoading());
    try {
      await _service.updateLoja(loja);
      emit(LojaLoaded(loja));
    } catch (e) {
      emit(LojaError('Falha ao atualizar loja: ${e.toString()}'));
    }
  }
}
