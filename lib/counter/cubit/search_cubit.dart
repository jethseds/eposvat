import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:posadmin/counter/model/product_model.dart';

class SearchCubit extends Cubit<List<ProductModel>> {
  SearchCubit() : super([]);

  void getList() => emit(state);

  void updateList(String query, List<ProductModel> list) {
    Iterable<ProductModel> searchedList = list
        .where(
          (item) => item.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    emit(searchedList.toList());
  }
}
