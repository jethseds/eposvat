import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:posadmin/counter/Auth/auth_bloc.dart';
import 'package:posadmin/counter/firebase_service/firestore_bloc.dart';
import 'package:posadmin/counter/firebase_service/firestore_service.dart';
import 'package:posadmin/counter/model/product_model.dart';
import 'package:posadmin/counter/view/expense_tracker_form_edit.dart';

class ExpenseTrackerPage extends StatelessWidget {
  const ExpenseTrackerPage({super.key});

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
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int thismonth = 0;
  int lastmonth = 0;
  Future<void> thisMonthandlastMonth() async {
    int? selectedYear = DateTime.now().year;
    int selectedMonth = DateTime.now().month;
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;
    final lastMonth = selectedMonth - 1;
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('expensestracker').get();

    int tempTotal = 0;
    int tempTotal2 = 0;

    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;

      if (timestamp != null) {
        final docDate = timestamp.toDate(); // Convert Timestamp to DateTime

        // Check if the year and month of docDate match the current year and month
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          int total = (doc['total'] is num) ? (doc['total'] as num).toInt() : 0;
          tempTotal += total;
        }
      }
    }

    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;

      if (timestamp != null) {
        final docDate = timestamp.toDate(); // Convert Timestamp to DateTime

        // Check if the year and month of docDate match the current year and month
        if (docDate.year == currentYear && docDate.month == lastMonth) {
          int total = (doc['total'] is num) ? (doc['total'] as num).toInt() : 0;
          tempTotal2 += total;
        }
      }
    }

    setState(() {
      thismonth = tempTotal;
      lastmonth = tempTotal2;
    });
  }

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

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    thisMonthandlastMonth();
    super.initState();
  }

  List<String> monthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  @override
  Widget build(BuildContext context) {
    SideMenuController sideMenuController = SideMenuController(initialPage: 4);
    String query = '';

    List<ProductModel> search(String query, List<ProductModel> list) {
      Iterable<ProductModel> searchedList = list
          .where(
            (item) => item.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      return searchedList.toList();
    }

    final formattedValue = NumberFormat.currency(
      locale: 'en_PH', // Use Philippine locale
      symbol: '₱', // Currency symbol
      decimalDigits: 2,
    ).format(thismonth);

    final formattedValue2 = NumberFormat.currency(
      locale: 'en_PH', // Use Philippine locale
      symbol: '₱', // Currency symbol
      decimalDigits: 2,
    ).format(lastmonth);

    final CollectionReference productsRef =
        FirebaseFirestore.instance.collection('products');
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
                        child: ListView(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Expense Tracker",
                                  style: TextStyle(
                                    fontSize: 30,
                                  ),
                                ),
                                Container(
                                  width: 300,
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      labelText: 'Search expenses name',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                // Row(
                                //   children: [
                                //     Container(
                                //       width: 450,
                                //       height: 50,
                                //       child: TextField(
                                //         controller: searchController,
                                //         onChanged: (value) {
                                //           setState(() {
                                //             query =
                                //                 value; // Update the search query on text change
                                //           });
                                //         },
                                //         decoration: InputDecoration(
                                //           contentPadding: EdgeInsets.all(15),
                                //           prefixIcon: Icon(Icons.search),
                                //           prefixIconColor:
                                //               Color.fromRGBO(171, 187, 194, 1),
                                //           fillColor:
                                //               Color.fromRGBO(57, 60, 73, 1),
                                //           filled: true,
                                //           hintStyle: TextStyle(
                                //               color: Color.fromRGBO(
                                //                   171, 187, 194, 1)),
                                //           hintText: "Search for expense name",
                                //           border: OutlineInputBorder(
                                //             borderRadius:
                                //                 BorderRadius.circular(10),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //     Padding(
                                //       padding:
                                //           const EdgeInsets.only(left: 10.0),
                                //       child: TextButton.icon(
                                //         style: TextButton.styleFrom(
                                //           iconColor: Colors.white,
                                //           shape: RoundedRectangleBorder(
                                //             borderRadius:
                                //                 BorderRadius.circular(8),
                                //           ),
                                //           backgroundColor:
                                //               Color.fromRGBO(57, 181, 74, 1),
                                //           fixedSize: Size(150, 40),
                                //         ),
                                //         onPressed: () {
                                //           setState(() {
                                //             query =
                                //                 ''; // Clear the search query
                                //             searchController
                                //                 .clear(); // Clear the TextField
                                //           });
                                //         },
                                //         icon: Icon(Icons.search),
                                //         label: Text(
                                //           'Search',
                                //           style: TextStyle(
                                //             fontWeight: FontWeight.w900,
                                //             color: Colors.white,
                                //             fontSize: 17,
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
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
                                      context.go('/expensetrackerform');
                                    },
                                    icon: Icon(Icons.add),
                                    label: const Text(
                                      'Add New Expense ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          fontSize: 17),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('expensestracker')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      // Check connection state
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }

                                      // Check for errors in the snapshot
                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      }

                                      // Ensure snapshot has data
                                      if (!snapshot.hasData ||
                                          snapshot.data!.docs.isEmpty) {
                                        return Center(
                                            child: Text('No expenses found.'));
                                      }

                                      final expenses = snapshot.data!.docs;

                                      // Group expenses by month and year
                                      final groupedExpenses = <String,
                                          List<Map<String, dynamic>>>{};

                                      for (var expenseSnapshot in expenses) {
                                        final expenseData = expenseSnapshot
                                            .data() as Map<String, dynamic>;
                                        var dateField = expenseData['date'];
                                        DateTime? date;

                                        // Capture the docID for this particular expense
                                        final docID = expenseSnapshot.id;
                                        print(
                                            docID); // This should print the unique docID for each expense

                                        // Add the docID to the expense data (important!)
                                        expenseData['docID'] = docID;

                                        // Handle date format (Timestamp or String)
                                        if (dateField is Timestamp) {
                                          date = dateField.toDate();
                                        } else if (dateField is String) {
                                          try {
                                            date = DateTime.parse(dateField);
                                          } catch (e) {
                                            print(
                                                'Error parsing date: $dateField');
                                          }
                                        }

                                        if (date != null) {
                                          final monthYear =
                                              "${date.year}-${date.month.toString().padLeft(2, '0')}";
                                          groupedExpenses.putIfAbsent(
                                              monthYear, () => []);
                                          groupedExpenses[monthYear]!
                                              .add(expenseData);
                                        }
                                      }

                                      final months = [
                                        'January',
                                        'February',
                                        'March',
                                        'April',
                                        'May',
                                        'June',
                                        'July',
                                        'August',
                                        'September',
                                        'October',
                                        'November',
                                        'December'
                                      ];

                                      return SingleChildScrollView(
                                        child: Column(
                                          children: months.map((month) {
                                            final monthYear =
                                                "2024-${(months.indexOf(month) + 1).toString().padLeft(2, '0')}";
                                            final expensesForMonth =
                                                groupedExpenses[monthYear] ??
                                                    [];

                                            if (expensesForMonth.isEmpty) {
                                              return SizedBox.shrink();
                                            }

                                            final filteredExpenses =
                                                expensesForMonth
                                                    .where((expense) {
                                              final title = expense['title']
                                                      ?.toLowerCase() ??
                                                  '';
                                              return title
                                                  .toString()
                                                  .contains(_searchQuery);
                                            }).toList();

                                            if (filteredExpenses.isEmpty) {
                                              return SizedBox.shrink();
                                            }

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 25),
                                                  child: Text(
                                                    month,
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      expensesForMonth.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final expense =
                                                        expensesForMonth[index];
                                                    final date =
                                                        (expense['date']
                                                                as Timestamp)
                                                            .toDate();
                                                    final docID = expense[
                                                        'docID']; // Now docID is part of expense
                                                    final expensetotal =
                                                        NumberFormat.currency(
                                                      locale:
                                                          'en_PH', // Use Philippine locale
                                                      symbol:
                                                          '₱', // Currency symbol
                                                      decimalDigits: 2,
                                                    ).format(expense['total']);
                                                    return Card(
                                                      child: ListTile(
                                                        subtitle: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                              width: (MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      500) /
                                                                  8,
                                                              child: IconButton(
                                                                onPressed: () {
                                                                  // Example: using docID
                                                                  context.go(
                                                                      '/expensetrackerformedit/$docID');
                                                                },
                                                                icon: Icon(
                                                                    Icons.edit,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            57,
                                                                            181,
                                                                            74,
                                                                            1)),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                    '${expense['title'] ?? 'No Title'}'),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                    '${expense['type'] ?? 'N/A'}'),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                    '${expensetotal}'),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                    '${DateFormat.yMMMMd('en_US').format(date)}'),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: (MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      500) /
                                                                  8,
                                                              child: IconButton(
                                                                onPressed: () {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'expensestracker')
                                                                      .doc(docID
                                                                          as String)
                                                                      .delete();
                                                                  context.go(
                                                                      '/expensetracker');
                                                                },
                                                                icon: Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    child: Column(
                                      children: [
                                        Container(
                                            padding: EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "CURRENT MONTH",
                                                        style: TextStyle(
                                                            fontSize: 25,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(height: 20),
                                                      Text(
                                                        "${formattedValue}",
                                                        style: TextStyle(
                                                            fontSize: 30,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )),
                                        SizedBox(height: 20),
                                        Container(
                                            padding: EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "LAST MONTH",
                                                        style: TextStyle(
                                                            fontSize: 25,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(height: 20),
                                                      Text(
                                                        "${formattedValue2}",
                                                        style: TextStyle(
                                                            fontSize: 30,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )),
                                      ],
                                    ))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
