part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {}

class Authenticated extends AuthState {
  @override
  List<Object?> get props => [];
}


class Unauthenticated extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthError extends AuthState{
  final String message;

  AuthError({required this.message});

  @override
  List<Object?> get props => [message];

}


