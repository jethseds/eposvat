part of 'dropdown_bloc.dart';

abstract class DropdownState {
  const DropdownState();
}

class DropdownInitalState extends DropdownState {}

class DropdownLoadingState extends DropdownState {
  final bool isLoading;
  DropdownLoadingState(this.isLoading);
}

class DropdownSuccessState extends DropdownState {
  final String value;
  DropdownSuccessState(this.value);
}

class DropdownFailedState extends DropdownState {
  DropdownFailedState();
}
