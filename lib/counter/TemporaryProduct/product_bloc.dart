import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:posadmin/counter/model/product_model.dart';

part 'product_state.dart';
part 'product_event.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    List<ProductModel> list = [];
    on<UpdateTemporaryList>((event, emit) {
      double subTotal = 0;
      double vat = 0.0;
      double total = 0;
      double change = 0;
      emit(ProductLoading());
      try {
        list.add(event.product);
        list.forEach((data) {
          subTotal = subTotal + data.price;
        });
        subTotal += event.serviceCharge;
        vat = subTotal * 0.12;
        total = subTotal + vat;
        change = event.cash - total;
        print('CHANGEEEEE $change');
        emit(ProductUpdated(list, subTotal, total, vat));
      } catch (e) {
        emit(ProductError('Error updating list'));
      }
    });
    on<UpdateTemporaryListValue>(
      (event, emit) {
        double subTotal = 0;
        double vat = 0.0;
        double total = 0;
        emit(ProductLoading());
        try {
          list.forEach((data) {
            subTotal = subTotal + data.price;
          });
          subTotal += event.serviceCharge;
          vat = subTotal * 0.12;
          total = subTotal + vat;
          emit(ProductUpdated(list, subTotal, total, vat));
        } catch (e) {
          emit(ProductError('Failed to fetch data'));
        }
      },
    );
    on<GetChange>(
      (event, emit) {
        double subTotal = 0;
        double vat = 0.0;
        double total = 0;
        double change = 0;
        emit(ProductLoading());
        try {
          list.forEach((data) {
            subTotal = subTotal + data.price;
          });
          subTotal += event.serviceCharge;
          vat = subTotal * 0.12;
          total = subTotal + vat;
          change = event.cash - total;
          emit(ProductChange(list, subTotal, change, total, vat));
        } catch (e) {
          emit(ProductError('Failed to fetch data'));
        }
      },
    );
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
        double subTotal = 0;
        double vat = 0.0;
        double total = 0;
        emit(ProductLoading());
        try {
          list.remove(event.product);
          list.forEach((data) {
            subTotal = subTotal + data.price;
            vat = subTotal * 0.12;
            total = subTotal + vat + event.serviceCharge;
          });
          emit(ProductUpdated(list, subTotal, total, vat));
        } catch (e) {
          emit(ProductError('Error removing item'));
        }
      },
    );
  }
}
