import 'package:posadmin/counter/model/product_model.dart';

class ReceiptModel {
  ReceiptModel(
    this.customerName,
    this.address,
    this.referenceNumber,
    this.amount,
    this.vat,
    this.total,
    this.POSoperator,
    this.dateTimeCreated,
    this.userEmail,
    this.paymentMethod,
    this.receiptCategory,
    this.products,
  );
  String customerName;
  String address;
  int referenceNumber;
  double amount;
  double vat;
  double total;
  String POSoperator;
  String dateTimeCreated;
  String userEmail;
  String paymentMethod;
  String receiptCategory;
  List<ProductModel> products;
}
