part of 'dropdown_bloc.dart';

abstract class DropdownEvent {
  DropdownEvent();
}

class DropdownUpdateValue extends DropdownEvent {
  DropdownUpdateValue(this.value);
  final String value;
}
