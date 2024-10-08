import 'package:flutter_bloc/flutter_bloc.dart';

part 'dropdown_event.dart';
part 'dropdown_state.dart';

class DropdownBloc extends Bloc<DropdownEvent, DropdownState> {
  DropdownBloc() : super(DropdownInitalState()) {
    on<DropdownEvent>(
      (event, emit) {},
    );

    on<DropdownUpdateValue>(
      (event, emit) {
        emit(DropdownLoadingState(true));
        try {
          emit(DropdownSuccessState(event.value));
        } catch (e) {
          emit(DropdownFailedState());
        }
      },
    );
  }
}
