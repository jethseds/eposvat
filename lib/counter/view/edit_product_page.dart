import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:posadmin/counter/firebase_service/firestore_bloc.dart';
import 'package:posadmin/counter/firebase_service/firestore_service.dart';
import 'package:posadmin/counter/model/product_model.dart';

class EditProductPage extends StatelessWidget {
  const EditProductPage({required this.code, super.key});
  final int code;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => FirestoreBloc(FirestoreService()))
        ],
        child: EditProductView(
          code: code,
        ));
  }
}

class EditProductView extends StatefulWidget {
  const EditProductView({required this.code, super.key});
  final int code;

  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  TextEditingController searchController = TextEditingController();
  TextEditingController productController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      context.go('/');
    }
    BlocProvider.of<FirestoreBloc>(context).add(GetProduct(widget.code));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(37, 40, 54, 1),
      body: SingleChildScrollView(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: BlocBuilder<FirestoreBloc, FirestoreState>(
              builder: (context, state) {
                if (state is FirestoreGetProduct) {
                  productController.text = state.product.name;
                  codeController.text = state.product.productCode.toString();
                  typeController.text = state.product.type;
                  priceController.text = state.product.price.toString();
                  quantityController.text = state.product.quantity.toString();
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        "Edit Product",
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
                            controller: searchController,
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
                            enabled: false,
                            controller: codeController,
                            style: TextStyle(
                              height: 3,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey,
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
                            // final ImagePicker pocker =
                            //     ImagePicker();

                            // final XFile? image =
                            //     await pocker.pickImage(
                            //         source: ImageSource
                            //             .gallery);
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  iconColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor:
                                      Color.fromRGBO(57, 181, 74, 1),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  iconColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor:
                                      Color.fromRGBO(57, 181, 74, 1),
                                  fixedSize: Size(200, 40)),
                              child: Text(
                                'Edit Product',
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
                                    UpdateProduct(
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
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
