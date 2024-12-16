import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:posadmin/counter/Dropdown/dropdown_bloc.dart';
import 'package:posadmin/counter/firebase_service/firestore_bloc.dart';
import 'package:posadmin/counter/firebase_service/firestore_service.dart';
import 'package:posadmin/counter/model/product_model.dart';

class ExpenseTrackerForm extends StatelessWidget {
  const ExpenseTrackerForm({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: (context) => FirestoreBloc(FirestoreService())),
      BlocProvider(create: (context) => DropdownBloc())
    ], child: ExpenseTrackerView());
  }
}

class ExpenseTrackerView extends StatefulWidget {
  const ExpenseTrackerView({super.key});

  @override
  State<ExpenseTrackerView> createState() => _ExpenseTrackerViewState();
}

class _ExpenseTrackerViewState extends State<ExpenseTrackerView> {
  TextEditingController productController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController productnameController = TextEditingController();
  TextEditingController producttypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // Automatically search as the user types
    codeController.addListener(() {
      searchProductByCode(codeController.text);
    });
  }

  List<DropdownMenuItem<String>> dropdownData = [
    DropdownMenuItem(
      child: Text(''),
      value: '',
    ),
    DropdownMenuItem(
      child: Text('Inventory Restock'),
      value: 'Inventory Restock',
    ),
    DropdownMenuItem(
      child: Text('Administrative Expense'),
      value: 'Administrative Expense',
    ),
    DropdownMenuItem(
      child: Text('Marketing Expense'),
      value: 'Marketing Expense',
    ),
    DropdownMenuItem(
      child: Text('Utilities Expense'),
      value: 'Utilities Expense',
    ),
    DropdownMenuItem(
      child: Text('Maintenance Expense'),
      value: 'Maintenance Expense',
    ),
    DropdownMenuItem(
      child: Text('Non-Operating Income'),
      value: 'Non-Operating Income',
    ),
    DropdownMenuItem(
      child: Text('Non-Operating Expense'),
      value: 'Non-Operating Expense',
    ),
    // DropdownMenuItem(
    //   child: Text('Operating Expense'),
    //   value: 'Operating Expense',
    // ),
    DropdownMenuItem(
      child: Text('Interest Revenue'),
      value: 'Interest Revenue',
    ),
    DropdownMenuItem(
      child: Text('Interest Expense'),
      value: 'Interest Expense',
    ),
  ];

  // List to store the search results
  List<DocumentSnapshot> productResults = [];
  String productname = "";
  String producttype = "";
  // Function to search for products by code
  // Function to search for products by code
  Future<void> searchProductByCode(String code) async {
    // Parse the input code into an integer
    int? parsedCode = int.tryParse(code);

    if (parsedCode != null) {
      try {
        // Searching for product by integer code
        var result = await FirebaseFirestore.instance
            .collection('products')
            .where('code', isEqualTo: parsedCode) // Use the parsed integer code
            .get();

        if (result.docs.isEmpty) {
          print("No products found for code: $parsedCode");
        } else {
          setState(() {
            productResults = result.docs; // Update the UI with the results
          });
        }
      } catch (e) {
        // Handle Firestore or network errors
        print("Error searching product by code: $e");
        setState(() {
          productResults = []; // Clear previous results
        });

        // Show error message
        const snackBar = SnackBar(
          content: Text('Error fetching product data. Please try again later.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      setState(() {
        productResults = []; // Clear results if the code is not a valid integer
      });
    }
  }

  // Function to populate the text fields with product info
  void selectProduct(DocumentSnapshot product) {
    setState(() {
      productname = product['name'] as String;
      producttypeController.text = product['type'] as String;
    });

    // Print the product name after selecting the product
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(37, 40, 54, 1),
        body: SingleChildScrollView(
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Expense Tracker",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Title of Expense:'),
                          ),
                          widgetTextField("Title Of Expense", titleController),
                        ],
                      )),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Restock Quantity:'),
                          ),
                          widgetTextField(
                              "Restock Quantity", quantityController),
                        ],
                      )),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Type of Expense:'),
                          ),
                          BlocBuilder<DropdownBloc, DropdownState>(
                            builder: (context, state) {
                              if (state is DropdownSuccessState) {
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    width:
                                        MediaQuery.of(context).size.width * .8,
                                    child: DropdownButton(
                                      value: state.value,
                                      hint: Text(
                                        'Type Of Expense',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey),
                                      ),
                                      padding: EdgeInsets.only(left: 10),
                                      style: TextStyle(
                                          color: Colors.black,
                                          height: 3,
                                          fontSize: 16),
                                      items: dropdownData,
                                      onChanged: (value) {
                                        BlocProvider.of<DropdownBloc>(context)
                                            .add(DropdownUpdateValue(value!));
                                        typeController.text = value;
                                      },
                                      iconSize: 0,
                                      underline: SizedBox(),
                                    ),
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    width:
                                        MediaQuery.of(context).size.width * .8,
                                    child: DropdownButton(
                                      hint: Text(
                                        'Type Of Expense',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      padding: EdgeInsets.only(left: 10),
                                      style: TextStyle(
                                          color: Colors.black,
                                          height: 3,
                                          fontSize: 16),
                                      items: dropdownData,
                                      onChanged: (value) {
                                        BlocProvider.of<DropdownBloc>(context)
                                            .add(DropdownUpdateValue(value!));
                                        typeController.text = value;
                                      },
                                      iconSize: 0,
                                      underline: SizedBox(),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      )),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Expense Total:'),
                          ),
                          widgetTextField("Expense Total", totalController),
                        ],
                      )),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Product Code:'),
                          ),
                          widgetTextField("Product Code", codeController),
                        ],
                      )),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Expense Date:'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * .8,
                              child: TextFormField(
                                controller: dateController,
                                readOnly: true, // Make the field non-editable
                                onTap: () async {
                                  // Select Date
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(
                                        2000), // Set earliest possible date
                                    lastDate: DateTime(
                                        2100), // Set latest possible date
                                  );

                                  if (pickedDate != null) {
                                    // Select Time
                                    TimeOfDay? pickedTime =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );

                                    if (pickedTime != null) {
                                      // Combine Date and Time
                                      DateTime finalDateTime = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );

                                      // Format the selected DateTime
                                      final formattedDateTime = DateFormat(
                                              "MMMM d, y 'at' h:mm:ss a 'UTC'Z")
                                          .format(finalDateTime.toUtc());
                                      dateController.text = formattedDateTime;

                                      // Save as Firestore Timestamp
                                      Timestamp firebaseTimestamp =
                                          Timestamp.fromDate(finalDateTime);
                                      print(
                                          firebaseTimestamp); // Now you can save it to Firestore
                                    }
                                  }
                                },
                                style:
                                    TextStyle(height: 3, color: Colors.black),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Select Date & Time',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ))
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 180,
                              child: ListView.builder(
                                itemCount: productResults.length,
                                itemBuilder: (context, index) {
                                  var product = productResults[index];
                                  productname = product['name'].toString();
                                  producttype = product['type'].toString();
                                  return ListTile(
                                    title: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: Text(
                                                'Product Name: ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child: Container(
                                            width: 200,
                                            height: 50,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child:
                                                Text(product['name'] as String),
                                          ))
                                        ],
                                      ),
                                    ), // Cast to String
                                    subtitle: Container(
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.only(top: 20),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: Text(
                                                'Product Type: ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child: Container(
                                            width: 200,
                                            height: 50,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child:
                                                Text(product['type'] as String),
                                          ))
                                        ],
                                      ),
                                    ), //  Cast to String
                                    onTap: () => selectProduct(
                                        product), // When selected, fill the text fields
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
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
                                      fixedSize: Size(200, 60)),
                                  child: Text(
                                    'ADD EXPENSE',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                        fontSize: 17),
                                  ),
                                  onPressed: () async {
                                    DateTime? finalDateTime;

                                    // Ensure that finalDateTime is set from the date picker
                                    if (dateController.text.isNotEmpty) {
                                      finalDateTime = DateFormat(
                                              "MMMM d, y 'at' h:mm:ss a 'UTC'Z")
                                          .parse(dateController.text)
                                          .toLocal();
                                    }

                                    int? total =
                                        int.tryParse(totalController.text);
                                    int? quantity =
                                        int.tryParse(quantityController.text);
                                    int? productcode =
                                        int.tryParse(codeController.text);
                                    // Ensure all fields are filled and finalDateTime is not null

                                    if (typeController.text ==
                                        'Inventory Restock') {
                                      if (titleController.text.isNotEmpty &&
                                          typeController.text.isNotEmpty &&
                                          totalController.text.isNotEmpty &&
                                          quantityController.text.isNotEmpty &&
                                          finalDateTime != null) {
                                        // Firebase Firestore operation
                                        FirebaseFirestore.instance
                                            .collection('expensestracker')
                                            .doc()
                                            .set({
                                          'title': titleController.text,
                                          'quantity': quantity,
                                          'productcode': productcode,
                                          'productname': productname,
                                          'producttype': producttype,
                                          'total': total,
                                          'type': typeController.text,
                                          'date': Timestamp.fromDate(
                                              finalDateTime), // Use the non-null finalDateTime
                                        });

                                        await FirebaseFirestore.instance
                                            .collection('products')
                                            .doc(productcode.toString())
                                            .update({
                                          'quantity': FieldValue.increment(
                                              quantity ?? 0),
                                        }).catchError((error) {
                                          print(
                                              'Failed to update quantity: $error');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Failed to update product quantity.'),
                                            ),
                                          );
                                        });

                                        // Reset form fields
                                        codeController.text = '';
                                        typeController.text = '';
                                        totalController.text = '';
                                        quantityController.text = '';
                                        context.go('/expensetracker');
                                      } else {
                                        const snackBar = SnackBar(
                                          content:
                                              Text('Please fill in the fields'),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      }
                                    } else {
                                      if (titleController.text.isNotEmpty &&
                                          totalController.text.isNotEmpty &&
                                          finalDateTime != null) {
                                        // Firebase Firestore operation
                                        FirebaseFirestore.instance
                                            .collection('expensestracker')
                                            .doc()
                                            .set({
                                          'title': titleController.text,
                                          'quantity': 0,
                                          'productcode': '',
                                          'productname': '',
                                          'producttype': producttype,
                                          'total': total,
                                          'type': typeController.text,
                                          'date': Timestamp.fromDate(
                                              finalDateTime), // Use the non-null finalDateTime
                                        });

                                        // Reset form fields
                                        typeController.text = '';
                                        totalController.text = '';
                                        context.go('/expensetracker');
                                      } else {
                                        const snackBar = SnackBar(
                                          content:
                                              Text('Please fill in the fields'),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      }
                                    }
                                  }),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    iconColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: Colors.grey,
                                    fixedSize: Size(200, 60)),
                                child: Text(
                                  'CANCEL',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                      fontSize: 17),
                                ),
                                onPressed: () {
                                  context.go('/expensetracker');
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget widgetTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * .8,
        child: TextFormField(
          controller: controller,
          style: TextStyle(height: 3, color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
