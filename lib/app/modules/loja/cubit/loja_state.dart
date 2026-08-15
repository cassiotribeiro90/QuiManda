import 'package:equatable/equatable.dart';
import '../model/loja_model.dart';

abstract class LojaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LojaInitial extends LojaState {}

class LojaLoading extends LojaState {}

class LojaLoaded extends LojaState {
  final LojaModel loja;
  LojaLoaded(this.loja);
  @override
  List<Object?> get props => [loja];
}

class LojaError extends LojaState {
  final String message;
  LojaError(this.message);
  @override
  List<Object?> get props => [message];
}
