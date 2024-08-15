import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posadmin/counter/model/product_model.dart';
import 'package:posadmin/counter/model/receipt_model.dart';

class FirestoreService {
  final CollectionReference productData =
      FirebaseFirestore.instance.collection('products');
  final CollectionReference userData =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference receiptsData =
      FirebaseFirestore.instance.collection('Receipts');
  final storageRef = FirebaseStorage.instance.ref();

  Future<void> assignReceiptToUser(int referenceNumber, String email) {
    return receiptsData
        .doc(referenceNumber.toString())
        .update({'userEmail': email});
  }

  Future<Iterable<ReceiptModel>> getReceipts() {
    return receiptsData
        .orderBy('referenceNumber', descending: true)
        .get()
        .then((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<ProductModel> list = [];
        return ReceiptModel(
          data['customerName'].toString(),
          data['address'].toString(),
          int.parse(data['referenceNumber'].toString()),
          double.parse(data['amount'].toString()),
          double.parse(data['vat'].toString()),
          double.parse(data['total'].toString()),
          data['POSoperator'].toString(),
          data['dateTimeCreated'].toString(),
          data['userEmail'].toString(),
          data['paymentMethod'].toString(),
          data['receiptCategory'].toString(),
          list,
        );
      }).toList();
    });
  }

  Future<void> addReceipt(ReceiptModel receipt) async {
    final receipts = await receiptsData
        .orderBy('referenceNumber', descending: true)
        .get()
        .then((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<ProductModel> list = [];
        return ReceiptModel(
          data['customerName'].toString(),
          data['address'].toString(),
          int.parse(data['referenceNumber'].toString()),
          double.parse(data['amount'].toString()),
          double.parse(data['vat'].toString()),
          double.parse(data['total'].toString()),
          data['POSoperator'].toString(),
          data['dateTimeCreated'].toString(),
          data['userEmail'].toString(),
          data['paymentMethod'].toString(),
          data['receiptCategory'].toString(),
          list,
        );
      }).toList();
    });
    int referenceNumber = receipt.referenceNumber + (receipts.length + 1);
    final receiptRef = receiptsData.doc(referenceNumber.toString()).set({
      'customerName': receipt.customerName,
      'address': receipt.address,
      'referenceNumber': referenceNumber,
      'amount': receipt.amount,
      'vat': receipt.vat,
      'total': receipt.total,
      'POSoperator': receipt.POSoperator,
      'dateTimeCreated': receipt.dateTimeCreated,
      'userEmail': receipt.userEmail,
      'paymentMethod': receipt.paymentMethod,
      'receiptCategory': receipt.receiptCategory,
    });
    print(receipt.products.length);
    for (final ProductModel element in receipt.products) {
      receiptsData
          .doc(referenceNumber.toString())
          .collection('products')
          .doc(element.productCode.toString())
          .set({
        'code': element.productCode,
        'name': element.name,
        'price': element.price,
        'quantity': element.quantity,
      });
    }

    return receiptRef;
  }

  Future<void> addProduct(ProductModel product) {
    final productRef = productData.doc(product.productCode.toString()).set({
      'name': product.name,
      'code': product.productCode,
      'type': product.type,
      'price': product.price,
      'quantity': product.quantity
    });

    return productRef;
  }

  Future<void> updateProduct(ProductModel product) {
    final productRef = productData.doc(product.productCode.toString()).update({
      'name': product.name,
      'code': product.productCode,
      'type': product.type,
      'price': product.price,
      'quantity': product.quantity
    });

    return productRef;
  }

  Future<void> removeProduct(int code) {
    return productData.doc(code.toString()).delete();
  }

  Future<Iterable<ProductModel>> getProducts() async {
    var snapshot = await productData.get();
    var futures = snapshot.docs.map((doc) async {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return ProductModel(
        int.parse(data['code'].toString()),
        data['name'].toString(),
        data['type'].toString(),
        int.parse(data['price'].toString()),
        int.parse(data['quantity'].toString()),
        await getProductImage(int.parse(data['code'].toString())),
      );
    });

    // Wait for all futures to complete and collect the results into a list
    var products = await Future.wait(futures);
    return products;
  }

  Future<ProductModel> getProduct(int code) async {
    final data = productData.doc(code.toString());
    final product = await data.get().then((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ProductModel(
        int.parse(data['code'].toString()),
        data['name'].toString(),
        data['type'].toString(),
        int.parse(data['price'].toString()),
        int.parse(data['quantity'].toString()),
        '',
      );
    });
    return product;
  }

  Future<Iterable<ProductModel>> getSpecificProducts(String type) async {
    var snapshot = await productData.where('type', isEqualTo: type).get();

    var future = snapshot.docs.map((doc) async {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return ProductModel(
        int.parse(data['code'].toString()),
        data['name'].toString(),
        data['type'].toString(),
        int.parse(data['price'].toString()),
        int.parse(data['quantity'].toString()),
        await getProductImage(int.parse(data['code'].toString())),
      );
    });
    var products = await Future.wait(future);
    return products;
  }

  Future<void> updateProductQuantity(int code, bool isAdd) async {
    final DocumentReference<Object?> data = productData.doc(code.toString());
    final product = await data.get().then((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ProductModel(
        int.parse(data['code'].toString()),
        data['name'].toString(),
        data['type'].toString(),
        int.parse(data['price'].toString()),
        int.parse(data['quantity'].toString()),
        '',
      );
    });
    if (isAdd) {
      productData
          .doc(code.toString())
          .update({'quantity': product.quantity + 1});
    } else {
      productData
          .doc(code.toString())
          .update({'quantity': product.quantity - 1});
    }
  }

  Future<void> uploadProductImage(XFile file, int code) {
    final userRef = storageRef.child('products/${code.toString()}');
    return userRef.putFile(
      File(file.path),
      SettableMetadata(
        contentType: "Image/png",
      ),
    );
  }

  Future<String?> getProductImage(int code) {
    return storageRef.child('products/${code.toString()}').getDownloadURL();
  }
}
