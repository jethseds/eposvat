part of 'servicecharge_bloc.dart';

abstract class ServicechargeState {}

class ServiceChargeInitialState extends ServicechargeState {}

class ServiceChargeLoadingState extends ServicechargeState {}

class GetServiceCharge extends ServicechargeState {
  final double serviceCharge;
  GetServiceCharge(this.serviceCharge);
}

class GetCash extends ServicechargeState {
  final double cash;
  GetCash(this.cash);
}

class GetComputaion extends ServicechargeState {
  final double subTotal;
  final double vat;
  final double total;
  final double change;
  GetComputaion(this.subTotal, this.vat, this.total, this.change);
}

class ServiceChargeFailed extends ServicechargeState {}
