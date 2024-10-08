import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posadmin/counter/firebase_service/firestore_service.dart';
import 'package:posadmin/counter/model/product_model.dart';
import 'package:posadmin/counter/model/receipt_model.dart';

part 'firestore_event.dart';
part 'firestore_state.dart';

class FirestoreBloc extends Bloc<FirestoreEvent, FirestoreState> {
  final FirestoreService firestoreService;
  FirestoreBloc(this.firestoreService) : super(FirestoreInitial()) {
    on<AssignReceiptToUser>(
      (event, emit) async {
        try {
          emit(FirestoreLoading());
          await firestoreService.assignReceiptToUser(
              event.referenceNumber, event.email);
          final userReceipts = await firestoreService.getReceipts();
          emit(FirestoreReceiptsLoaded(userReceipts.toList()));
        } catch (e) {
          emit(FirestoreError('Failed to assign receipt to user'));
        }
      },
    );
    on<AddReceipt>(
      (event, emit) async {
        try {
          emit(FirestoreLoading());
          await firestoreService.addReceipt(event.receipt);
          emit(FirestoreOperationSuccess('Receipt added successfully'));
          print('success');
        } catch (e) {
          print(e);

          emit(FirestoreError('Failed to add receipt'));
        }
      },
    );

    on<AddProduct>((event, emit) async {
      try {
        emit(FirestoreLoading());
        await firestoreService.addProduct(event.product);
        emit(FirestoreOperationSuccess('Product added!'));
      } catch (e) {
        emit(FirestoreError('Product Failed'));
      }
    });

    on<GetProducts>((event, emit) async {
      try {
        emit(FirestoreLoading());

        final products = await firestoreService.getProducts();
        emit(FirestoreProductLoaded(products.toList()));
      } catch (e) {
        print(e);
        emit(FirestoreError('Failed to load products'));
      }
    });

    on<UpdateProducts>((event, emit) async {
      try {
        emit(FirestoreLoading());
        final products = await firestoreService.getProducts();
        Iterable<ProductModel> searchedList = products
            .where(
              (item) =>
                  item.name.toLowerCase().contains(event.query.toLowerCase()),
            )
            .toList();
        emit(FirestoreProductsUpdated(searchedList.toList()));
      } catch (e) {
        emit(FirestoreError('Failed to load searched Products'));
      }
    });
    on<GetReceipts>(
      (event, emit) async {
        try {
          emit(FirestoreLoading());
          final userReceipts = await firestoreService.getReceipts();
          emit(FirestoreReceiptsLoaded(userReceipts.toList()));
        } catch (e) {
          print(e);
          emit(FirestoreError('Failed to load user Receipts'));
        }
      },
    );

    on<UpdateReceipts>((event, emit) async {
      try {
        emit(FirestoreLoading());
        final receipts = await firestoreService.getReceipts();
        Iterable<ReceiptModel> searchedList = receipts
            .where(
              (item) => item.referenceNumber.toString().contains(event.query),
            )
            .toList();
        emit(FirestoreReceiptsUpdated(searchedList.toList()));
      } catch (e) {
        emit(FirestoreError('Failed to load searched Receipts'));
      }
    });

    on<GetSpecificProducts>((event, emit) async {
      emit(FirestoreLoading());
      try {
        final specificProducts =
            await firestoreService.getSpecificProducts(event.type);
        emit(FirestoreSpecificProductLoaded(specificProducts.toList()));
      } catch (e) {
        emit(FirestoreError('Failed to load specific Products'));
      }
    });

    on<UpdateSpecificProducts>((event, emit) async {
      emit(FirestoreLoading());
      try {
        final specificProducts =
            await firestoreService.getSpecificProducts(event.type);
        Iterable<ProductModel> searchedList = specificProducts
            .where(
              (item) =>
                  item.name.toLowerCase().contains(event.query.toLowerCase()),
            )
            .toList();
        emit(FirestoreUpdateSpecificProductLoaded(searchedList.toList()));
      } catch (e) {
        emit(FirestoreError('Failed to load updated specific Products'));
      }
    });

    on<UpdateProductQuantity>(
      (event, emit) async {
        emit(FirestoreLoading());
        try {
          await firestoreService.updateProductQuantity(event.code, event.isAdd);
          final specificProducts =
              await firestoreService.getSpecificProducts(event.type);
          emit(FirestoreSpecificProductLoaded(specificProducts.toList()));
        } catch (e) {
          emit(FirestoreError('Failed to load specific Products'));
        }
      },
    );
    on<GetProduct>(
      (event, emit) async {
        emit(FirestoreLoading());
        try {
          ProductModel product = await firestoreService.getProduct(event.code);
          emit(FirestoreGetProduct(product));
        } catch (e) {
          emit(FirestoreError('Failed to load product'));
        }
      },
    );
    on<UpdateProduct>(
      (event, emit) {
        emit(FirestoreLoading());
        try {
          firestoreService.updateProduct(event.product);
          emit(FirestoreOperationSuccess('Product updated successfully'));
        } catch (e) {
          emit(FirestoreError('Failed to update product'));
        }
      },
    );
    on<RemoveProduct>(
      (event, emit) async {
        emit(FirestoreLoading());
        try {
          await firestoreService.removeProduct(event.code);
          final list = await firestoreService.getProducts();
          emit(FirestoreProductLoaded(list.toList()));
        } catch (e) {
          emit(FirestoreError('Failed to remove product'));
        }
      },
    );
    on<UploadProductImage>(
      (event, emit) async {
        emit(FirestoreLoading());
        try {
          await firestoreService.uploadProductImage(event.file, event.code);
          emit(
              FirestoreOperationSuccess('Product Image uploaded successfully'));
        } catch (e) {
          emit(FirestoreError('Failed to upload product image'));
        }
      },
    );

    on<UpdateProductImage>(
      (event, emit) async {
        emit(FirestoreLoading());
        try {
          await firestoreService.uploadProductImage(event.file, event.code);
          final products = await firestoreService.getProducts();
          emit(FirestoreProductLoaded(products.toList()));
        } catch (e) {
          emit(FirestoreError('Failed to upload product image'));
        }
      },
    );

    on<GetProductImage>(
      (event, emit) async {
        emit(FirestoreLoading());
        try {
          final image = await firestoreService.getProductImage(event.code);
          emit(FirestoreImageLoaded(image));
        } catch (e) {
          emit(FirestoreError('Failed to get product image'));
        }
      },
    );

    on<GetCount>(
      (event, emit) async {
        emit(FirestoreLoading());
        try {
          int count = await firestoreService.getCount();
          emit(FirestoreGetCount(count));
        } catch (e) {
          emit(FirestoreError('Error getting count'));
        }
      },
    );
  }
}
