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

class ExpenseTrackerFormEdit extends StatelessWidget {
  final String docID;
  const ExpenseTrackerFormEdit({super.key, required this.docID});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => FirestoreBloc(FirestoreService())),
          BlocProvider(create: (context) => DropdownBloc())
        ],
        child: ExpenseTrackerFormEditView(
          docID: docID,
        ));
  }
}

class ExpenseTrackerFormEditView extends StatefulWidget {
  final String docID;
  const ExpenseTrackerFormEditView({super.key, required this.docID});

  @override
  State<ExpenseTrackerFormEditView> createState() =>
      _ExpenseTrackerFormEditViewState();
}

class _ExpenseTrackerFormEditViewState
    extends State<ExpenseTrackerFormEditView> {
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

    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection(
              'expensestracker') // Replace with your Firestore collection name
          .doc(widget.docID)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          setState(() {
            codeController.text = data['productcode'].toString();
            typeController.text = data['type'].toString();
            totalController.text = data['total'].toString();
            quantityController.text = data['quantity'].toString();
            titleController.text = data['title'].toString();

            // Cast 'date' field to Timestamp and convert to DateTime
            Timestamp timestamp = data['date'] as Timestamp;
            DateTime date = timestamp.toDate(); // Convert Timestamp to DateTime

            // Format the date as 'Oct 29, 2024 at 1:05 AM'
            dateController.text =
                DateFormat('MMM dd, yyyy ' 'at hh:mm a').format(date);

            productnameController.text = data['productname'].toString();
            producttypeController.text = data['producttype'].toString();
          });
        }
      } else {
        // Handle document not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document not found')),
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
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
    int? parsedCode = int.tryParse(code);

    if (parsedCode != null) {
      try {
        var result = await FirebaseFirestore.instance
            .collection('products')
            .where('code', isEqualTo: parsedCode)
            .get();

        if (result.docs.isEmpty) {
          print("No products found for code: $parsedCode");
        } else {
          setState(() {
            productResults = result.docs; // Update the UI with the results
          });
        }
      } catch (e) {
        print("Error searching product by code: $e");
        setState(() {
          productResults = [];
        });

        const snackBar = SnackBar(
          content: Text('Error fetching product data. Please try again later.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      setState(() {
        productResults = [];
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
                  Text(
                    "Add Expense Tracker ${widget.docID}",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            widgetTextField(
                                "Title Of Expense", titleController),
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
                                      width: MediaQuery.of(context).size.width *
                                          .8,
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
                                      width: MediaQuery.of(context).size.width *
                                          .8,
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
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * .8,
                                child: TextFormField(
                                  controller: codeController,
                                  onChanged: searchProductByCode,
                                  style:
                                      TextStyle(height: 3, color: Colors.black),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: 'Product Code',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          Text('Product Name: '),
                                          Text(product['name'] as String)
                                        ],
                                      ),
                                    ), // Cast to String
                                    subtitle: Container(
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.only(top: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          Text('Product Type: '),
                                          Text(product['type'] as String)
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
                          child: Column(
                        children: [
                          widgetTextField(
                              "Restock Quantity", quantityController),
                          widgetTextField("Expense Total", totalController),
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
                            context.go('/expensetracker');
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
                            fixedSize: Size(200, 40),
                          ),
                          child: Text(
                            'Edit Expense Tracker',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                          onPressed: () {
                            DateTime? finalDateTime;

                            // Ensure that finalDateTime is set from the date picker
                            if (dateController.text.isNotEmpty) {
                              try {
                                // Try different formats for parsing
                                final formats = [
                                  DateFormat("MMMM d, y 'at' h:mm:ss a 'UTC'"),
                                  DateFormat(
                                      "MMM d, y 'at' h:mm a"), // For abbreviated month
                                  DateFormat(
                                      "MMMM d, y 'at' h:mm a") // For full month
                                ];

                                // Try parsing with each format
                                for (var format in formats) {
                                  try {
                                    finalDateTime = format
                                        .parse(dateController.text)
                                        .toLocal();
                                    break; // Exit the loop if parsing is successful
                                  } catch (e) {
                                    // Ignore the error and try the next format
                                    continue;
                                  }
                                }

                                // If no valid date is found after trying all formats
                                if (finalDateTime == null) {
                                  throw FormatException("Invalid date format");
                                }
                              } catch (e) {
                                // Handle invalid date format error
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Invalid date format")));
                              }
                            }

                            int? total = int.tryParse(totalController.text);
                            int? quantity =
                                int.tryParse(quantityController.text);
                            int? productcode =
                                int.tryParse(codeController.text);

                            // Ensure all required fields are filled
                            if (titleController.text.isNotEmpty &&
                                typeController.text.isNotEmpty &&
                                totalController.text.isNotEmpty &&
                                quantityController.text.isNotEmpty) {
                              // Prepare the data to update
                              Map<String, dynamic> updateData = {
                                'title': titleController.text,
                                'quantity': quantity,
                                'productcode': productcode,
                                'productname': productname,
                                'producttype': producttype,
                                'total': total,
                                'type': typeController.text,
                              };

                              // If a valid date is provided, include it in the update
                              if (finalDateTime != null) {
                                updateData['date'] =
                                    Timestamp.fromDate(finalDateTime);
                              }

                              // Perform the update in Firestore
                              FirebaseFirestore.instance
                                  .collection('expensestracker')
                                  .doc(widget.docID)
                                  .update(updateData);

                              // Reset form fields
                              codeController.text = '';
                              typeController.text = '';
                              totalController.text = '';
                              quantityController.text = '';
                              context.go('/expensetracker');
                            } else {
                              // Show an error message if required fields are not filled
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Please fill in all fields')));
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
