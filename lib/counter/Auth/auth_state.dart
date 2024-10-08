part of 'auth_bloc.dart';

abstract class AuthState {
  const AuthState();

  List<Object> get props => [];
}

class AuthInitState extends AuthState {}

class AuthLoadingState extends AuthState {
  final bool isLoading;

  AuthLoadingState({required this.isLoading});
}

class AuthLoginSuccess extends AuthState {
  final String Message;
  AuthLoginSuccess(this.Message);
}

class AuthFailedState extends AuthState {
  final String Message;

  const AuthFailedState(this.Message);

  @override
  List<Object> get props => [Message];
}
