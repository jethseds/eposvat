part of 'firestore_bloc.dart';

abstract class FirestoreState {}

class FirestoreInitial extends FirestoreState {}

class FirestoreLoading extends FirestoreState {}

class FirestoreProductLoaded extends FirestoreState {
  final List<ProductModel> product;
  FirestoreProductLoaded(this.product);
}

class FirestoreOperationSuccess extends FirestoreState {
  final String message;

  FirestoreOperationSuccess(this.message);
}

class FirestoreError extends FirestoreState {
  final String errorMessage;

  FirestoreError(this.errorMessage);
}

class FirestoreImageLoaded extends FirestoreState {
  FirestoreImageLoaded(this.image);
  final String? image;
}

class FirestoreProductsUpdated extends FirestoreState {
  FirestoreProductsUpdated(this.products);
  final List<ProductModel> products;
}

class FirestoreReceiptsLoaded extends FirestoreState {
  final List<ReceiptModel> userReceipts;
  FirestoreReceiptsLoaded(this.userReceipts);
}

class FirestoreReceiptsUpdated extends FirestoreState {
  final List<ReceiptModel> userReceipts;
  FirestoreReceiptsUpdated(this.userReceipts);
}

class FirestoreSpecificProductLoaded extends FirestoreState {
  final List<ProductModel> SpecificProducts;
  FirestoreSpecificProductLoaded(this.SpecificProducts);
}

class FirestoreUpdateSpecificProductLoaded extends FirestoreState {
  final List<ProductModel> SpecificProducts;
  FirestoreUpdateSpecificProductLoaded(this.SpecificProducts);
}

class FirestoreGetProduct extends FirestoreState {
  final ProductModel product;
  FirestoreGetProduct(this.product);
}

class FirestoreGetCount extends FirestoreState {
  final int count;
  FirestoreGetCount(this.count);
}
