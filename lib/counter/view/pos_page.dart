import 'dart:io';

import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posadmin/counter/Auth/auth_bloc.dart';
import 'package:posadmin/counter/TemporaryProduct/product_bloc.dart';
import 'package:posadmin/counter/firebase_service/firestore_bloc.dart';
import 'package:posadmin/counter/firebase_service/firestore_service.dart';
import 'package:posadmin/counter/model/product_model.dart';
import 'package:posadmin/counter/model/receipt_model.dart';

class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) => ProductBloc(),
      ),
      BlocProvider(create: (context) => FirestoreBloc(FirestoreService())),
      BlocProvider(create: (context) => AuthBloc())
    ], child: PosView());
  }
}

class PosView extends StatefulWidget {
  const PosView({super.key});

  @override
  State<PosView> createState() => _PosViewState();
}

class _PosViewState extends State<PosView> {
  TextEditingController searchController = TextEditingController();

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
    BlocProvider.of<FirestoreBloc>(context).add(GetSpecificProducts('Tires'));
    BlocProvider.of<ProductBloc>(context).add(GetTemporaryList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SideMenuController sideMenuController = SideMenuController(initialPage: 0);
    List<ProductModel> temporaryProductList = [];
    String typeHeader = 'Tires';
    return Scaffold(
      backgroundColor: Color.fromRGBO(37, 40, 54, 1),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SideMenu(
            title: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                  child: Image.asset('assets/images/Dashboard__Logo.png')),
            ),
            style: SideMenuStyle(
                unselectedIconColor: Color.fromRGBO(57, 181, 74, 1),
                selectedIconColor: Colors.white,
                selectedColor: Color.fromRGBO(57, 181, 74, 1),
                backgroundColor: Color.fromRGBO(31, 29, 43, 1),
                openSideMenuWidth: 65),
            items: [
              SideMenuItem(
                icon: Icon(
                  Icons.home,
                ),
                onTap: (index, sideMenuController) {
                  sideMenuController.changePage(index);
                  context.go('/pos');
                },
              ),
              SideMenuItem(
                icon: Icon(Icons.receipt),
                onTap: (index, sideMenuController) {
                  sideMenuController.changePage(index);
                  context.go('/expenses');
                },
              ),
              SideMenuItem(
                icon: Icon(Icons.inventory),
                onTap: (index, sideMenuController) {
                  sideMenuController.changePage(index);
                  context.go('/inventory');
                },
              ),
              SideMenuItem(
                icon: Icon(Icons.exit_to_app),
                onTap: (index, sideMenuController) {
                  BlocProvider.of<AuthBloc>(context).add(SignOutUser());
                  context.go('/');
                },
              ),
            ],
            controller: sideMenuController,
          ),
          BlocBuilder<FirestoreBloc, FirestoreState>(
            builder: (context, state) {
              if (state is FirestoreSpecificProductLoaded) {
                final products = state.SpecificProducts;
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * .55,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hi, Operator!",
                                  style: TextStyle(fontSize: 30),
                                ),
                                Text(
                                  DateFormat('EEEE, d MMM yyyy')
                                      .format(DateTime.now()),
                                  style: TextStyle(
                                    color: Color.fromRGBO(224, 230, 233, 1),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 240,
                              height: 60,
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(15),
                                  prefixIcon: Icon(Icons.search),
                                  prefixIconColor:
                                      Color.fromRGBO(171, 187, 194, 1),
                                  fillColor: Color.fromRGBO(57, 60, 73, 1),
                                  filled: true,
                                  hintStyle: TextStyle(
                                      color: Color.fromRGBO(171, 187, 194, 1)),
                                  hintText: "Search for product name...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    BlocProvider.of<FirestoreBloc>(context).add(
                                      GetSpecificProducts('Tires'),
                                    );
                                    typeHeader = 'Tires';
                                  },
                                  child: Text('Tires')),
                              GestureDetector(
                                  onTap: () {
                                    BlocProvider.of<FirestoreBloc>(context).add(
                                      GetSpecificProducts('Gear Oils'),
                                    );
                                    typeHeader = 'Gear Oils';
                                  },
                                  child: Text('Gear Oils')),
                              GestureDetector(
                                  onTap: () {
                                    BlocProvider.of<FirestoreBloc>(context).add(
                                      GetSpecificProducts('Shocks'),
                                    );
                                    typeHeader = 'Shocks';
                                  },
                                  child: Text('Shocks')),
                              GestureDetector(
                                  onTap: () {
                                    BlocProvider.of<FirestoreBloc>(context).add(
                                      GetSpecificProducts('Bolts'),
                                    );
                                    typeHeader = 'Bolts';
                                  },
                                  child: Text('Bolts')),
                              GestureDetector(
                                  onTap: () {
                                    BlocProvider.of<FirestoreBloc>(context).add(
                                      GetSpecificProducts('Gloves'),
                                    );
                                    typeHeader = 'Gloves';
                                  },
                                  child: Text('Gloves')),
                              GestureDetector(
                                  onTap: () {
                                    BlocProvider.of<FirestoreBloc>(context).add(
                                      GetSpecificProducts('Accessories'),
                                    );
                                    typeHeader = 'Accessories';
                                  },
                                  child: Text('Accessories')),
                            ],
                          ),
                        ),
                        Divider(
                          color: Color.fromRGBO(57, 60, 73, 1),
                        ),
                        Row(
                          children: [
                            Text(
                              'Choose ${typeHeader}',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.70,
                          width: MediaQuery.of(context).size.width,
                          child: products.length > 0
                              ? GridView.count(
                                  crossAxisCount: 3,
                                  children:
                                      List.generate(products.length, (index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          BlocProvider.of<ProductBloc>(context)
                                              .add(
                                            UpdateTemporaryList(
                                                ProductModel(
                                                    products[index].productCode,
                                                    products[index].name,
                                                    products[index].type,
                                                    products[index].price,
                                                    1,
                                                    ''),
                                                temporaryProductList),
                                          );
                                          BlocProvider.of<FirestoreBloc>(
                                                  context)
                                              .add(
                                            UpdateProductQuantity(
                                                products[index].productCode,
                                                false,
                                                typeHeader),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  Color.fromRGBO(31, 29, 43, 1),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 100,
                                                  width: 100,
                                                  child: products[index]
                                                          .image!
                                                          .isNotEmpty
                                                      ? Image.network(
                                                          products[index]
                                                              .image!,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Placeholder(),
                                                ),
                                                Text(products[index].name),
                                                Text(
                                                    "₱ ${products[index].price}"),
                                                Text(
                                                  "${products[index].quantity} Available",
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          171, 187, 194, 1)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                )
                              : Container(),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Center(
                  child: Text('Loading'),
                );
              }
            },
          ),
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoaded) {
                int subtotal = 0;
                int serviceCharge = 50;
                int vat = 0;
                int total = 0;
                return Container(
                  width: 350,
                  color: Color.fromRGBO(31, 29, 43, 1),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('Item'),
                              Text('Qty'),
                              Text('Price'),
                            ],
                          ),
                        ),
                        Divider(),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.60,
                          child: ListView.builder(
                            itemCount: state.products.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onDoubleTap: () {
                                  BlocProvider.of<ProductBloc>(context).add(
                                      DeleteProduct(state.products[index]));
                                  BlocProvider.of<FirestoreBloc>(context).add(
                                    UpdateProductQuantity(
                                        state.products[index].productCode,
                                        true,
                                        typeHeader),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(45, 48, 62, 1),
                                      border: Border.all(
                                          width: 1, color: Colors.white),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(state.products[index].name),
                                      Text(state.products[index].quantity
                                          .toString()),
                                      Text(
                                        '₱ ${state.products[index].price}',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sub Total'),
                            Text('₱ $subtotal'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Service Charge'),
                            Text('₱ ${serviceCharge}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('VAT 12%'),
                            Text('₱ ${vat}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total'),
                            Text('₱ ${total}'),
                          ],
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Color.fromRGBO(57, 181, 74, 1),
                              fixedSize: Size(500, 50)),
                          onPressed: () {
                            const snackBar = SnackBar(
                              content: Text('Select a product'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                          child: Text(
                            'Pay Now',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontSize: 17),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              } else if (state is ProductUpdated) {
                double subtotal = 0;
                int serviceCharge = 50;
                double vat = 0.0;
                double total = 0;

                state.products.forEach((data) {
                  subtotal = subtotal + data.price;
                  vat = subtotal * 0.12;
                  total = subtotal + vat + serviceCharge;
                });
                return Container(
                  width: 350,
                  color: Color.fromRGBO(31, 29, 43, 1),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('Item'),
                              Text('Qty'),
                              Text('Price'),
                            ],
                          ),
                        ),
                        Divider(),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.60,
                          child: ListView.builder(
                            itemCount: state.products.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onDoubleTap: () {
                                  BlocProvider.of<ProductBloc>(context).add(
                                      DeleteProduct(state.products[index]));
                                  BlocProvider.of<FirestoreBloc>(context).add(
                                    UpdateProductQuantity(
                                        state.products[index].productCode,
                                        true,
                                        typeHeader),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(45, 48, 62, 1),
                                      border: Border.all(
                                          width: 1, color: Colors.white),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(state.products[index].name),
                                      Text(state.products[index].quantity
                                          .toString()),
                                      Text(
                                        '₱ ${state.products[index].price}',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sub Total'),
                            Text('₱ $subtotal'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Service Charge'),
                            Text('₱ $serviceCharge'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('VAT 12%'),
                            Text('₱ $vat'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total'),
                            Text('₱ $total'),
                          ],
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Color.fromRGBO(57, 181, 74, 1),
                              fixedSize: Size(500, 50)),
                          onPressed: () {
                            BlocProvider.of<FirestoreBloc>(context)
                                .add(GetReceipts());
                            List<ProductModel> prods = state.products;
                            if (state.products.length > 0) {
                              BlocProvider.of<FirestoreBloc>(context).add(
                                AddReceipt(
                                  ReceiptModel(
                                      '',
                                      '',
                                      DateTime.now().toLocal().year * 10000,
                                      subtotal,
                                      vat,
                                      total,
                                      'Admin',
                                      DateTime.now().toLocal().toString(),
                                      '',
                                      'cash',
                                      '',
                                      prods),
                                ),
                              );
                              context.go('/expenses');
                            } else {
                              const snackBar = SnackBar(
                                content: Text('Select a product'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          },
                          child: Text(
                            'Pay Now',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontSize: 17),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          )
        ],
      ),
    );
  }
}
