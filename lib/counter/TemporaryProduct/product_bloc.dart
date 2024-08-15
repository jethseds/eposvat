import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:posadmin/counter/model/product_model.dart';

part 'product_state.dart';
part 'product_event.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    List<ProductModel> list = [];
    on<UpdateTemporaryList>((event, emit) {
      emit(ProductLoading());
      try {
        list.add(event.product);
        emit(ProductUpdated(list));
      } catch (e) {
        emit(ProductError('Error updating list'));
      }
    });
    on<GetTemporaryList>(
      (event, emit) {
        emit(ProductLoading());
        try {
          emit(ProductLoaded(list));
        } catch (e) {
          emit(ProductError('Failed to fetch data'));
        }
      },
    );
    on<DeleteProduct>(
      (event, emit) {
        emit(ProductLoading());
        try {
          list.remove(event.product);
          emit(ProductUpdated(list));
        } catch (e) {
          emit(ProductError('Error removing item'));
        }
      },
    );
  }
}
