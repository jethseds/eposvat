part of 'firestore_bloc.dart';

abstract class FirestoreEvent {}

class AssignReceiptToUser extends FirestoreEvent {
  AssignReceiptToUser(this.referenceNumber, this.email);
  final int referenceNumber;
  final String email;
}

class AddReceipt extends FirestoreEvent {
  AddReceipt(this.receipt);
  final ReceiptModel receipt;
}

class AddProduct extends FirestoreEvent {
  AddProduct(this.product);
  final ProductModel product;
}

class GetProducts extends FirestoreEvent {}

class UpdateProducts extends FirestoreEvent {
  UpdateProducts(this.query);
  final String query;
}

class GetReceipts extends FirestoreEvent {}

class UpdateReceipts extends FirestoreEvent {
  UpdateReceipts(this.query);
  final String query;
}

class GetSpecificProducts extends FirestoreEvent {
  GetSpecificProducts(this.type);
  final String type;
}

class UpdateProductQuantity extends FirestoreEvent {
  UpdateProductQuantity(this.code, this.isAdd, this.type);
  final int code;
  final bool isAdd;
  final String type;
}

class GetProduct extends FirestoreEvent {
  GetProduct(this.code);
  final int code;
}

class UpdateProduct extends FirestoreEvent {
  UpdateProduct(this.product);
  final ProductModel product;
}

class RemoveProduct extends FirestoreEvent {
  RemoveProduct(this.code);
  final int code;
}

class UploadProductImage extends FirestoreEvent {
  UploadProductImage(this.file, this.code);
  final XFile file;
  final int code;
}

class GetProductImage extends FirestoreEvent {
  GetProductImage(this.code);
  final int code;
}
