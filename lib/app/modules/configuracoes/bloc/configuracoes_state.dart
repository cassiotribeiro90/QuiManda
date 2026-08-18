import '../models/loja_model.dart';

abstract class ConfiguracoesState {
  const ConfiguracoesState();
}

class ConfiguracoesInitial extends ConfiguracoesState {}

class ConfiguracoesLoading extends ConfiguracoesState {}

class ConfiguracoesLoaded extends ConfiguracoesState {
  final LojaModel loja;
  const ConfiguracoesLoaded(this.loja);
}

class ConfiguracoesSaving extends ConfiguracoesState {}

class ConfiguracoesSuccess extends ConfiguracoesState {
  final String message;
  final LojaModel loja;
  const ConfiguracoesSuccess(this.message, this.loja);
}

class ConfiguracoesError extends ConfiguracoesState {
  final String message;
  const ConfiguracoesError(this.message);
}
