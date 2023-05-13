part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;
  final VoidCallback? onFinished;

  AuthLogin({required this.email, required this.password, this.onFinished});

  @override
  List<Object?> get props => [email, password, onFinished];
}

class AuthReload extends AuthEvent {
  @override
  List<Object?> get props => [];
}

class AuthLogout extends AuthEvent {
  final VoidCallback? onFinished;

  AuthLogout({this.onFinished});

  @override
  List<Object?> get props => [];
}

class AuthSignup extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String imageUrl;
  final VoidCallback? onFinished;

  AuthSignup({required this.firstName, required this.lastName,required this.email, required this.password, this.onFinished, required this.imageUrl});

  @override
  List<Object?> get props => [firstName, lastName,email, password, onFinished, imageUrl];
}

class AuthResetPassword extends AuthEvent {
  final String email;
  final VoidCallback? onFinished;


  AuthResetPassword({required this.email, required this.onFinished});

  @override
  List<Object?> get props => [email, onFinished];
}



