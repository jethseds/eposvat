import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:posadmin/counter/Auth/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService = AuthService();

  AuthBloc() : super(AuthInitState()) {
    on<AuthEvent>((event, emit) {});

    on<SignInUser>((event, emit) async {
      emit(AuthLoadingState(isLoading: true));
      try {
        await authService.signInUser(event.email, event.password);
        emit(AuthLoadingState(isLoading: false));
        emit(AuthLoginSuccess('Logged in!'));
      } catch (e) {
        emit(AuthFailedState('Error logging in'));
      }
    });

    on<SignOutUser>((event, emit) async {
      emit(AuthLoadingState(isLoading: true));
      try {
        await authService.signOutUser();
        emit(AuthLoadingState(isLoading: false));
        emit(AuthLoginSuccess('Signed out'));
      } catch (e) {
        emit(AuthFailedState('Error signing out'));
      }
    });
  }
}
