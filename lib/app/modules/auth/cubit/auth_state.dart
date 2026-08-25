import 'package:equatable/equatable.dart';
import '../model/lojista_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  String toString() => 'AuthInitial';
}

class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  String toString() => 'AuthLoading';
}

class AuthPhoneSent extends AuthState {
  final String telefone;
  final int tempoExpiracao;
  const AuthPhoneSent(this.telefone, this.tempoExpiracao);
  @override
  List<Object?> get props => [telefone, tempoExpiracao];
  @override
  String toString() => 'AuthPhoneSent(telefone: $telefone)';
}

class AuthOtpVerifying extends AuthState {
  const AuthOtpVerifying();
  @override
  String toString() => 'AuthOtpVerifying';
}

class AuthAuthenticated extends AuthState {
  final LojistaModel lojista;
  final String token;
  const AuthAuthenticated(this.lojista, this.token);
  @override
  List<Object?> get props => [lojista, token];
  @override
  String toString() => 'AuthAuthenticated(lojista: ${lojista.nome})';
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
  @override
  String toString() => 'AuthUnauthenticated';
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
  @override
  String toString() => 'AuthError(message: $message)';
}
