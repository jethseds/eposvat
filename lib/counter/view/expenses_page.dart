import 'dart:convert';
import 'dart:io';

import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:posadmin/counter/Auth/auth_bloc.dart';
import 'package:posadmin/counter/firebase_service/firestore_bloc.dart';
import 'package:posadmin/counter/firebase_service/firestore_service.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: (context) => AuthBloc()),
      BlocProvider(create: (context) => FirestoreBloc(FirestoreService()))
    ], child: ExpensesView());
  }
}

class ExpensesView extends StatefulWidget {
  const ExpensesView({super.key});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  final permissionCamera = Permission.camera;
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  String? code;
  final user = FirebaseAuth.instance.currentUser;
  final searchController = TextEditingController();

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
    BlocProvider.of<FirestoreBloc>(context).add(
      GetReceipts(),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SideMenuController sideMenuController = SideMenuController(initialPage: 1);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(37, 40, 54, 1),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideMenu(
              title: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Image.asset('assets/images/Dashboard__Logo.png'),
                ),
              ),
              style: SideMenuStyle(
                  unselectedIconColor: Color.fromRGBO(57, 181, 74, 1),
                  selectedIconColor: Colors.white,
                  selectedColor: Color.fromRGBO(57, 181, 74, 1),
                  backgroundColor: Color.fromRGBO(31, 29, 43, 1),
                  displayMode: SideMenuDisplayMode.compact),
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
                  icon: Icon(Icons.report),
                  onTap: (index, sideMenuController) {
                    sideMenuController.changePage(index);
                    context.go('/financialreport');
                  },
                ),
                SideMenuItem(
                  icon: Icon(Icons.list),
                  onTap: (index, sideMenuController) {
                    sideMenuController.changePage(index);
                    context.go('/expensetracker');
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
                if (state is FirestoreReceiptsLoaded) {
                  final receipts = state.userReceipts;
                  return Container(
                    width: MediaQuery.of(context).size.width - 70,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Receipts",
                                  style: TextStyle(
                                    fontSize: 30,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 450,
                                      height: 50,
                                      child: TextField(
                                        controller: searchController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(15),
                                          prefixIcon: Icon(Icons.search),
                                          prefixIconColor:
                                              Color.fromRGBO(171, 187, 194, 1),
                                          fillColor:
                                              Color.fromRGBO(57, 60, 73, 1),
                                          filled: true,
                                          hintStyle: TextStyle(
                                              color: Color.fromRGBO(
                                                  171, 187, 194, 1)),
                                          hintText:
                                              "Search for Reference Number",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: TextButton.icon(
                                        style: TextButton.styleFrom(
                                            iconColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            backgroundColor:
                                                Color.fromRGBO(57, 181, 74, 1),
                                            fixedSize: Size(150, 40)),
                                        onPressed: () {
                                          BlocProvider.of<FirestoreBloc>(
                                                  context)
                                              .add(UpdateReceipts(
                                            searchController.text,
                                          ));
                                          searchController.text = '';
                                        },
                                        icon: Icon(Icons.search),
                                        label: Text(
                                          'Search',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              fontSize: 17),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height < 820
                                  ? MediaQuery.of(context).size.height * 0.79
                                  : MediaQuery.of(context).size.height * 0.89,
                              width: MediaQuery.of(context).size.width - 65,
                              child: GridView.count(
                                childAspectRatio: 4 / 2,
                                crossAxisCount: 3,
                                children:
                                    List.generate(receipts.length, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: GestureDetector(
                                      onTap: () async {
                                        print('taptap');
                                        final status =
                                            await permissionCamera.request();
                                        if (status.isGranted) {
                                          _qrBarCodeScannerDialogPlugin
                                              .getScannedQrBarCode(
                                                  context: context,
                                                  onCode: (code) {
                                                    setState(() {
                                                      final json = jsonDecode(
                                                              code.toString())
                                                          as Map<String,
                                                              dynamic>;
                                                      this.code = code;
                                                      BlocProvider.of<
                                                                  FirestoreBloc>(
                                                              context)
                                                          .add(
                                                        AssignReceiptToUser(
                                                            state
                                                                .userReceipts[
                                                                    index]
                                                                .referenceNumber,
                                                            json['email']
                                                                .toString()),
                                                      );
                                                    });
                                                  });
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(31, 29, 43, 1),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Center(
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                height: 100,
                                                width: 80,
                                                child: Image.asset(
                                                  'assets/images/DefaultReceiptImage.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                820
                                                            ? 180
                                                            : 220,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  820
                                                              ? 100
                                                              : 120,
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right: 10,
                                                                    top: 10),
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 3,
                                                                    bottom: 3,
                                                                    right: 8,
                                                                    left: 8),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 0.5,
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                receipts[index]
                                                                        .receiptCategory
                                                                        .isEmpty
                                                                    ? 'No Tag'
                                                                    : receipts[
                                                                            index]
                                                                        .receiptCategory,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                820
                                                            ? 180
                                                            : 230,
                                                    height: 80,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                "Ref no. ${receipts[index].referenceNumber}"),
                                                            Text(
                                                                "₱ ${receipts[index].total}"),
                                                          ],
                                                        ),
                                                      ],
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
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (state is FirestoreReceiptsUpdated) {
                  final receipts = state.userReceipts;
                  return Container(
                    width: MediaQuery.of(context).size.width - 70,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Expenses Tracker",
                                  style: TextStyle(
                                    fontSize: 30,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 450,
                                      height: 50,
                                      child: TextField(
                                        controller: searchController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(15),
                                          prefixIcon: Icon(Icons.search),
                                          prefixIconColor:
                                              Color.fromRGBO(171, 187, 194, 1),
                                          fillColor:
                                              Color.fromRGBO(57, 60, 73, 1),
                                          filled: true,
                                          hintStyle: TextStyle(
                                              color: Color.fromRGBO(
                                                  171, 187, 194, 1)),
                                          hintText:
                                              "Search for Reference Number",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: TextButton.icon(
                                        style: TextButton.styleFrom(
                                            iconColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            backgroundColor:
                                                Color.fromRGBO(57, 181, 74, 1),
                                            fixedSize: Size(150, 40)),
                                        onPressed: () {
                                          BlocProvider.of<FirestoreBloc>(
                                                  context)
                                              .add(UpdateReceipts(
                                            searchController.text,
                                          ));
                                          searchController.text = '';
                                        },
                                        icon: Icon(Icons.search),
                                        label: Text(
                                          'Search',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              fontSize: 17),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height < 820
                                  ? MediaQuery.of(context).size.height * 0.79
                                  : MediaQuery.of(context).size.height * 0.89,
                              width: MediaQuery.of(context).size.width - 65,
                              child: GridView.count(
                                childAspectRatio: 4 / 2,
                                crossAxisCount: 3,
                                children:
                                    List.generate(receipts.length, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: GestureDetector(
                                      onTap: () async {
                                        print('taptap');
                                        final status =
                                            await permissionCamera.request();
                                        if (status.isGranted) {
                                          _qrBarCodeScannerDialogPlugin
                                              .getScannedQrBarCode(
                                                  context: context,
                                                  onCode: (code) {
                                                    setState(() {
                                                      final json = jsonDecode(
                                                              code.toString())
                                                          as Map<String,
                                                              dynamic>;
                                                      this.code = code;
                                                      BlocProvider.of<
                                                                  FirestoreBloc>(
                                                              context)
                                                          .add(
                                                        AssignReceiptToUser(
                                                            state
                                                                .userReceipts[
                                                                    index]
                                                                .referenceNumber,
                                                            json['email']
                                                                .toString()),
                                                      );
                                                    });
                                                  });
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(31, 29, 43, 1),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Center(
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                height: 100,
                                                width: 80,
                                                child: Image.asset(
                                                  'assets/images/DefaultReceiptImage.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .height <
                                                                820
                                                            ? 180
                                                            : 220,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height <
                                                                  820
                                                              ? 100
                                                              : 120,
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right: 10,
                                                                    top: 10),
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 3,
                                                                    bottom: 3,
                                                                    right: 8,
                                                                    left: 8),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 0.5,
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                receipts[index]
                                                                        .receiptCategory
                                                                        .isEmpty
                                                                    ? 'No Tag'
                                                                    : receipts[
                                                                            index]
                                                                        .receiptCategory,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .height <
                                                                820
                                                            ? 180
                                                            : 230,
                                                    height: 80,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                "Ref no. ${receipts[index].referenceNumber}"),
                                                            Text(
                                                                "₱ ${receipts[index].total}"),
                                                          ],
                                                        ),
                                                      ],
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
                                }),
                              ),
                            ),
                          ],
                        ),
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
          ],
        ),
      ),
    );
  }
}
