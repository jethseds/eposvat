import 'package:flutter_bloc/flutter_bloc.dart';

class DropdownCubit extends Cubit<String> {
  DropdownCubit() : super('');
  void updateValue(String value) => emit(value);
}
