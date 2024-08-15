import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posadmin/counter/firebase_service/firestore_bloc.dart';
import 'package:posadmin/counter/firebase_service/firestore_service.dart';
import 'package:posadmin/counter/model/product_model.dart';

class AddProductPage extends StatelessWidget {
  const AddProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: (context) => FirestoreBloc(FirestoreService()))
    ], child: AddProductView());
  }
}

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  TextEditingController productController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(37, 40, 54, 1),
      body: SingleChildScrollView(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  "Add Product",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * .8,
                    child: TextFormField(
                      controller: productController,
                      style: TextStyle(
                        height: 3,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        focusColor: Colors.white,
                        hintText: 'Enter Product Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * .8,
                    child: TextFormField(
                      controller: codeController,
                      style: TextStyle(
                        height: 3,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        focusColor: Colors.white,
                        hintText: 'Enter Product Code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * .8,
                    child: TextFormField(
                      controller: typeController,
                      style: TextStyle(
                        height: 3,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        focusColor: Colors.white,
                        hintText: 'Enter Product Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * .8,
                    child: TextFormField(
                      controller: priceController,
                      style: TextStyle(
                        height: 3,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        focusColor: Colors.white,
                        hintText: 'Enter Product Price',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * .8,
                    child: TextFormField(
                      controller: quantityController,
                      style: TextStyle(
                        height: 3,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        focusColor: Colors.white,
                        hintText: 'Enter Product Quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                        iconColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Color.fromRGBO(57, 181, 74, 1),
                        fixedSize: Size(200, 40)),
                    label: Text(
                      'Select Image',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 17),
                    ),
                    icon: Icon(Icons.image),
                    onPressed: () async {
                      final ImagePicker pocker = ImagePicker();

                      final XFile? image =
                          await pocker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        BlocProvider.of<FirestoreBloc>(context).add(
                            UploadProductImage(
                                image, int.parse(codeController.text.trim())));
                      }
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            iconColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Color.fromRGBO(57, 181, 74, 1),
                            fixedSize: Size(200, 40)),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 17),
                        ),
                        onPressed: () {
                          context.go('/inventory');
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            iconColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Color.fromRGBO(57, 181, 74, 1),
                            fixedSize: Size(200, 40)),
                        child: Text(
                          'Add Product',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 17),
                        ),
                        onPressed: () {
                          if (productController.text.isNotEmpty &&
                              codeController.text.isNotEmpty &&
                              typeController.text.isNotEmpty &&
                              priceController.text.isNotEmpty &&
                              quantityController.text.isNotEmpty) {
                            ProductModel product = new ProductModel(
                              int.parse(
                                codeController.text.trim(),
                              ),
                              productController.text.trim(),
                              typeController.text.trim(),
                              int.parse(
                                priceController.text.trim(),
                              ),
                              int.parse(
                                quantityController.text.trim(),
                              ),
                              '',
                            );
                            BlocProvider.of<FirestoreBloc>(
                              context,
                            ).add(
                              AddProduct(
                                product,
                              ),
                            );
                            productController.text = '';
                            codeController.text = '';
                            typeController.text = '';
                            priceController.text = '';
                            quantityController.text = '';
                            context.go('/inventory');
                          } else {
                            const snackBar = SnackBar(
                              content: Text(
                                'Please fill in the fields',
                              ),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
