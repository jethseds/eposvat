import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posadmin/counter/Auth/auth_bloc.dart';
import 'package:posadmin/counter/cubit/login_cubit.dart';
import 'package:posadmin/counter/cubit/search_cubit.dart';
import 'package:posadmin/counter/firebase_service/firestore_bloc.dart';
import 'package:posadmin/counter/firebase_service/firestore_service.dart';
import 'package:posadmin/counter/model/product_model.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: (context) => AuthBloc()),
      BlocProvider(
        create: (context) => FirestoreBloc(FirestoreService()),
      )
    ], child: InventoryView());
  }
}

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
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
    BlocProvider.of<FirestoreBloc>(context).add(GetProducts());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SideMenuController sideMenuController = SideMenuController(initialPage: 2);
    String query = '';

    List<ProductModel> search(String query, List<ProductModel> list) {
      Iterable<ProductModel> searchedList = list
          .where(
            (item) => item.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      return searchedList.toList();
    }

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
                if (state is FirestoreLoading) {
                  CircularProgressIndicator();
                }
                if (state is FirestoreProductLoaded) {
                  List<ProductModel> products;

                  products = state.product;

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
                                  "Inventory Management",
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
                                        onChanged: (value) {
                                          query = value;
                                        },
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
                                          hintText: "Search for product name",
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
                                              .add(UpdateProducts(
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
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                        iconColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        backgroundColor:
                                            Color.fromRGBO(57, 181, 74, 1),
                                        fixedSize: Size(200, 40)),
                                    onPressed: () {
                                      context.go('/add');
                                    },
                                    icon: Icon(Icons.add),
                                    label: Text(
                                      'Add New Product',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          fontSize: 17),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              height: 40,
                              width: MediaQuery.of(context).size.width - 65,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(''),
                                  Text(
                                    'Name',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Code',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Type',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Price',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Quantity',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Image',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text('  '),
                                ],
                              ),
                            ),
                            products.isNotEmpty
                                ? Container(
                                    height: MediaQuery.of(context).size.height <
                                            820
                                        ? MediaQuery.of(context).size.height *
                                            0.70
                                        : MediaQuery.of(context).size.height *
                                            0.74,
                                    width:
                                        MediaQuery.of(context).size.width - 65,
                                    child: ListView.builder(
                                      itemCount: state.product.length,
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: (MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          500) /
                                                      8,
                                                  child: IconButton(
                                                      onPressed: () {
                                                        context.go(
                                                            '/edit/${products[index].productCode}');
                                                      },
                                                      icon: Icon(
                                                        Icons.edit,
                                                        color: Color.fromRGBO(
                                                            57, 181, 74, 1),
                                                      )),
                                                ),
                                                Container(
                                                  width: (MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          100) /
                                                      8,
                                                  child: Text(
                                                    products[index].name,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(
                                                            92, 111, 136, 1),
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                Container(
                                                  width: (MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          100) /
                                                      8,
                                                  child: Text(
                                                    products[index]
                                                        .productCode
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(
                                                            92, 111, 136, 1),
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                Container(
                                                  width: (MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          100) /
                                                      8,
                                                  child: Text(
                                                    products[index].type,
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(
                                                            92, 111, 136, 1),
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                Container(
                                                  width: (MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          100) /
                                                      8,
                                                  child: Text(
                                                    '₱ ${products[index].price}',
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(
                                                            92, 111, 136, 1),
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                Container(
                                                  width: (MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          100) /
                                                      8,
                                                  child: Text(
                                                    products[index]
                                                        .quantity
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(
                                                            92, 111, 136, 1),
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    final ImagePicker pocker =
                                                        ImagePicker();

                                                    final XFile? image =
                                                        await pocker.pickImage(
                                                            source: ImageSource
                                                                .gallery);

                                                    if (image != null) {
                                                      BlocProvider.of<
                                                                  FirestoreBloc>(
                                                              context)
                                                          .add(UpdateProductImage(
                                                              image,
                                                              int.parse(products[
                                                                      index]
                                                                  .productCode
                                                                  .toString())));
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 80,
                                                    child: state.product[index]
                                                            .image!.isNotEmpty
                                                        ? Image.network(
                                                            state.product[index]
                                                                .image!,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Placeholder(),
                                                  ),
                                                ),
                                                Container(
                                                  width: (MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          500) /
                                                      8,
                                                  child: IconButton(
                                                      onPressed: () {
                                                        BlocProvider.of<
                                                                    FirestoreBloc>(
                                                                context)
                                                            .add(RemoveProduct(
                                                                products[index]
                                                                    .productCode));
                                                        context
                                                            .go('/inventory');
                                                      },
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Center(
                                    child: Text('No Products'),
                                  )
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (state is FirestoreProductsUpdated) {
                  List<ProductModel> products;

                  products = state.products;

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
                                  "Inventory Management",
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
                                        onChanged: (value) {
                                          query = value;
                                        },
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
                                          hintText: "Search for product name",
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
                                              .add(UpdateProducts(
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
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                        iconColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        backgroundColor:
                                            Color.fromRGBO(57, 181, 74, 1),
                                        fixedSize: Size(200, 40)),
                                    onPressed: () {
                                      context.go('/add');
                                    },
                                    icon: Icon(Icons.add),
                                    label: Text(
                                      'Add New Product',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          fontSize: 17),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              height: 40,
                              width: MediaQuery.of(context).size.width - 65,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(''),
                                  Text(
                                    'Name',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Code',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Type',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Price',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Quantity',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Image',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text('  '),
                                ],
                              ),
                            ),
                            products.isNotEmpty
                                ? Container(
                                    height: MediaQuery.of(context).size.height <
                                            820
                                        ? MediaQuery.of(context).size.height *
                                            0.79
                                        : MediaQuery.of(context).size.height *
                                            0.74,
                                    width:
                                        MediaQuery.of(context).size.width - 65,
                                    child: ListView.builder(
                                      itemCount: state.products.length,
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                IconButton(
                                                    onPressed: () {},
                                                    icon: Icon(
                                                      Icons.edit,
                                                      color: Color.fromRGBO(
                                                          57, 181, 74, 1),
                                                    )),
                                                Text(
                                                  products[index].name,
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          92, 111, 136, 1),
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Text(
                                                  products[index]
                                                      .productCode
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          92, 111, 136, 1),
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Text(
                                                  products[index].type,
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          92, 111, 136, 1),
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Text(
                                                  '₱ ${products[index].price}',
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          92, 111, 136, 1),
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Text(
                                                  products[index]
                                                      .quantity
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          92, 111, 136, 1),
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    final ImagePicker pocker =
                                                        ImagePicker();

                                                    final XFile? image =
                                                        await pocker.pickImage(
                                                            source: ImageSource
                                                                .gallery);

                                                    if (image != null) {
                                                      BlocProvider.of<
                                                                  FirestoreBloc>(
                                                              context)
                                                          .add(UpdateProductImage(
                                                              image,
                                                              int.parse(products[
                                                                      index]
                                                                  .productCode
                                                                  .toString())));
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 80,
                                                    child: Image.network(
                                                      products[index].image!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                    onPressed: () {
                                                      BlocProvider.of<
                                                                  FirestoreBloc>(
                                                              context)
                                                          .add(RemoveProduct(
                                                              products[index]
                                                                  .productCode));
                                                      context.go('/inventory');
                                                    },
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Center(
                                    child: Text('No Products'),
                                  )
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
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
                                  "Inventory Management",
                                  style: TextStyle(
                                    fontSize: 30,
                                  ),
                                ),
                                Container(
                                  width: 450,
                                  height: 50,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(15),
                                      prefixIcon: Icon(Icons.search),
                                      prefixIconColor:
                                          Color.fromRGBO(171, 187, 194, 1),
                                      fillColor: Color.fromRGBO(57, 60, 73, 1),
                                      filled: true,
                                      hintStyle: TextStyle(
                                          color:
                                              Color.fromRGBO(171, 187, 194, 1)),
                                      hintText: "Search for product name",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                        iconColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        backgroundColor:
                                            Color.fromRGBO(57, 181, 74, 1),
                                        fixedSize: Size(200, 40)),
                                    onPressed: () {
                                      context.go('/add');
                                    },
                                    icon: Icon(Icons.add),
                                    label: Text(
                                      'Add New Product',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          fontSize: 17),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              height: 40,
                              width: MediaQuery.of(context).size.width - 65,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(''),
                                  Text(
                                    'Name',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Code',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Type',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Price',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Quantity',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Image',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 111, 136, 1),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(''),
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height < 820
                                  ? MediaQuery.of(context).size.height * 0.79
                                  : MediaQuery.of(context).size.height * 0.74,
                              width: MediaQuery.of(context).size.width - 65,
                              child: Text('Loading'),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
