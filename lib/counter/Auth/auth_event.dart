part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();

  List<Object> get propos => [];
}

class SignInUser extends AuthEvent {
  final String email;
  final String password;
  SignInUser(this.email, this.password);
}

class SignOutUser extends AuthEvent {}
