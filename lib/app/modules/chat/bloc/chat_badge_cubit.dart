import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/chat_repository.dart';

class ChatBadgeCubit extends Cubit<int> {
  final ChatRepository _repository;

  ChatBadgeCubit(this._repository) : super(0);

  Future<void> updateBadge() async {
    try {
      final count = await _repository.contarNaoLidasLojista();
      emit(count);
    } catch (e) {
      // Silenciosamente falha em caso de erro de rede no badge
    }
  }

  void setBadge(int count) {
    emit(count);
  }
}
