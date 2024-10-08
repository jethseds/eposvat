part of 'servicecharge_bloc.dart';

abstract class ServicechargeEvent {}

class SetServiceCharge extends ServicechargeEvent {
  final double serviceCharge;
  SetServiceCharge(this.serviceCharge);
}

class SetCash extends ServicechargeEvent {
  final double cash;
  SetCash(this.cash);
}

class SetComputation extends ServicechargeEvent {
  final List<ProductModel> products;
  final double serviceCharge;
  final double cash;
  SetComputation(this.products, this.cash, this.serviceCharge);
}
