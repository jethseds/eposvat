import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:posadmin/counter/model/product_model.dart';

part 'servicecharge_event.dart';
part 'servicecharge_state.dart';

class ServicechargeBloc extends Bloc<ServicechargeEvent, ServicechargeState> {
  ServicechargeBloc() : super(ServiceChargeInitialState()) {
    on<SetServiceCharge>(
      (event, emit) {
        emit(ServiceChargeLoadingState());
        try {
          emit(ServiceChargeLoadingState());
          emit(GetServiceCharge(event.serviceCharge));
        } catch (e) {
          emit(ServiceChargeFailed());
        }
      },
    );

    on<SetCash>(
      (event, emit) {
        emit(ServiceChargeLoadingState());
        try {
          emit(GetCash(event.cash));
        } catch (e) {
          emit(ServiceChargeFailed());
        }
      },
    );

    on<SetComputation>(
      (event, emit) {
        emit(ServiceChargeLoadingState());
        double subTotal = 0;
        double vat = 0.0;
        double total = 0;
        double change = 0;
        try {
          List<ProductModel> products = event.products;
          products.forEach((data) {
            subTotal = subTotal + data.price;
            vat = subTotal * 0.12;
            total = subTotal + vat + event.serviceCharge;
            change = total - event.cash;
          });
          emit(GetComputaion(subTotal, vat, total, change));
        } catch (e) {
          emit(ServiceChargeFailed());
        }
      },
    );
  }
}
