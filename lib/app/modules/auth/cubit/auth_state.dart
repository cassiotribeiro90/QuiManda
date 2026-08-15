import 'package:equatable/equatable.dart';
import '../model/lojista_model.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthPhoneSent extends AuthState {
  final String telefone;
  final int tempoExpiracao;
  AuthPhoneSent(this.telefone, this.tempoExpiracao);
  @override
  List<Object?> get props => [telefone, tempoExpiracao];
}

class AuthOtpVerifying extends AuthState {}

class AuthAuthenticated extends AuthState {
  final LojistaModel lojista;
  final String token;
  AuthAuthenticated(this.lojista, this.token);
  @override
  List<Object?> get props => [lojista, token];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
