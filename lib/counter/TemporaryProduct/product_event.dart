part of 'product_bloc.dart';

abstract class ProductEvent {}

class UpdateTemporaryList extends ProductEvent {
  UpdateTemporaryList(this.product, this.list);
  final ProductModel product;
  final List<ProductModel> list;
}

class GetTemporaryList extends ProductEvent {}

class DeleteProduct extends ProductEvent {
  DeleteProduct(this.product);
  final ProductModel product;
}
