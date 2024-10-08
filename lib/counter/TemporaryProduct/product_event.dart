part of 'product_bloc.dart';

abstract class ProductEvent {}

class UpdateTemporaryList extends ProductEvent {
  UpdateTemporaryList(this.product, this.list, this.serviceCharge, this.cash);
  final ProductModel product;
  final double serviceCharge;
  final double cash;
  final List<ProductModel> list;
}

class UpdateTemporaryListValue extends ProductEvent {
  UpdateTemporaryListValue(this.list, this.serviceCharge, this.cash);
  final double serviceCharge;
  final double cash;
  final List<ProductModel> list;
}

class GetChange extends ProductEvent {
  GetChange(this.list, this.serviceCharge, this.cash);
  final double serviceCharge;
  final double cash;
  final List<ProductModel> list;
}

class GetTemporaryList extends ProductEvent {}

class DeleteProduct extends ProductEvent {
  DeleteProduct(this.product, this.serviceCharge, this.cash);
  final ProductModel product;
  final double serviceCharge;
  final double cash;
}
