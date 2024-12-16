import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:posadmin/counter/Auth/auth_bloc.dart';
import 'package:posadmin/counter/firebase_service/firestore_bloc.dart';
import 'package:posadmin/counter/firebase_service/firestore_service.dart';

class FinancialReport extends StatelessWidget {
  const FinancialReport({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(
          create: (context) => FirestoreBloc(FirestoreService()),
        ),
      ],
      child: const FinancialReportView(),
    );
  }
}

class FinancialReportView extends StatefulWidget {
  const FinancialReportView({super.key});

  @override
  State<FinancialReportView> createState() => _FinancialReportViewState();
}

class _FinancialReportViewState extends State<FinancialReportView> {
  int? selectedYear = 2024;
  List<int> years = List.generate(7, (index) => 2024 + index);

  int selectedMonth = DateTime.now().month; // Start with the current month

  final List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  double monthlyTotal = 0.0;
  double purchasesTotal = 0.0;
  double nonOperatingExpenseTotal = 0.0;
  double OperatingExpenseTotal = 0.0;
  double interestRevenueTotal = 0.0;
  double interestExpenseTotal = 0.0;
  double nonOperatingIncomeTotal = 0.0;
  double expenseTotalCurrentMonthTotal = 0.0;
  // Method to calculate totals
  Future<void> calculateTotals() async {
    await totalRevenue();
    await purchases();
    await nonOperatingExpense();
    await OperatingExpense();
    await interestRevenue();
    await interestExpense();
    await nonOperatingIncome();
    await expenseTotalCurrentMonth();
    await restockQuantityLastMonth();
    await operatingexpenseData();
    await administrativeexpenseData();
    await marketingexpenseData();
    await utilitiesexpenseData();
    await maintenanceexpenseData();
    await totalVat();
  }

  Future<void> totalRevenue() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;

    // Check if the selected year is in the future
    if (currentYear! > DateTime.now().year) {
      // Set to 0.0 if it's a future year (no data should be available)
      setState(() {
        monthlyTotal = 0.0;
      });
      return;
    }

    double tempTotal = 0.0;

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Receipts').get();

    final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS");

    for (var doc in querySnapshot.docs) {
      final dateString = doc['dateTimeCreated'] as String?;
      if (dateString != null) {
        try {
          final docDate = dateFormat.parse(dateString);
          if (docDate.year == currentYear && docDate.month == currentMonth) {
            double total =
                (doc['total'] is num) ? (doc['total'] as num).toDouble() : 0.0;
            tempTotal += total;
          }
        } catch (e) {
          print("Error parsing date: $e");
        }
      }
    }

    // Ensure that tempTotal is a valid number (not NaN or Infinity)
    setState(() {
      monthlyTotal = tempTotal.isFinite ? tempTotal : 0.0;
    });
  }

  double totalvatistaxexpense = 0.0;
  Future<void> totalVat() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;

    // Check if the selected year is in the future
    if (currentYear! > DateTime.now().year) {
      // Set to 0.0 if it's a future year (no data should be available)
      setState(() {
        monthlyTotal = 0.0;
      });
      return;
    }

    double tempTotal = 0.0;

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Receipts').get();

    final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS");

    for (var doc in querySnapshot.docs) {
      final dateString = doc['dateTimeCreated'] as String?;
      if (dateString != null) {
        try {
          final docDate = dateFormat.parse(dateString);
          if (docDate.year == currentYear && docDate.month == currentMonth) {
            double total =
                (doc['vat'] is num) ? (doc['vat'] as num).toDouble() : 0.0;
            tempTotal += total;
          }
        } catch (e) {
          print("Error parsing date: $e");
        }
      }
    }

    // Ensure that tempTotal is a valid number (not NaN or Infinity)
    setState(() {
      totalvatistaxexpense = tempTotal;
      restockQuantityLastMonth();
    });
  }

  Future<void> purchases() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;

    // Check if the selected year is in the future
    if (currentYear! > DateTime.now().year) {
      setState(() {
        purchasesTotal = 0.0;
      });
      return;
    }

    double tempTotal = 0.0;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expensestracker')
        .where('type', isEqualTo: 'Inventory Restock')
        .get();

    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;
      if (timestamp != null) {
        final docDate = timestamp.toDate();
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          double total =
              (doc['total'] is num) ? (doc['total'] as num).toDouble() : 0.0;
          tempTotal += total;
        }
      }
    }

    // Ensure that tempTotal is a valid number (not NaN or Infinity)
    setState(() {
      purchasesTotal = tempTotal.isFinite ? tempTotal : 0.0;
    });
  }

  double purchasesTotalLastMonth = 0.0;
  Future<void> purchasesLastMonth() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth - 1;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expensestracker')
        .where('type', isEqualTo: 'Inventory Restock')
        .get();

    double tempTotal = 0.0;

    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;

      if (timestamp != null) {
        final docDate = timestamp.toDate(); // Convert Timestamp to DateTime

        // Check if the year and month of docDate match the current year and month
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          double total =
              (doc['total'] is num) ? (doc['total'] as num).toDouble() : 0;
          tempTotal += total;
        }
      }
    }

    setState(() {
      purchasesTotalLastMonth = tempTotal;
    });
  }

  Future<void> nonOperatingExpense() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expensestracker')
        .where('type', isEqualTo: 'Non-Operating Expense')
        .get();

    double tempTotal = 0.0;

    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;

      if (timestamp != null) {
        final docDate = timestamp.toDate(); // Convert Timestamp to DateTime

        // Check if the year and month of docDate match the current year and month
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          double total =
              (doc['total'] is num) ? (doc['total'] as num).toDouble() : 0;
          tempTotal += total;
        }
      }
    }

    setState(() {
      nonOperatingExpenseTotal = tempTotal;
    });
  }

  Future<void> OperatingExpense() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expensestracker')
        .where('type', isEqualTo: 'Operating Expense')
        .get();

    double tempTotal = 0.0;

    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;

      if (timestamp != null) {
        final docDate = timestamp.toDate(); // Convert Timestamp to DateTime

        // Check if the year and month of docDate match the current year and month
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          double total =
              (doc['total'] is num) ? (doc['total'] as num).toDouble() : 0;
          tempTotal += total;
        }
      }
    }

    setState(() {
      OperatingExpenseTotal = tempTotal;
    });
  }

  Future<void> interestRevenue() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expensestracker')
        .where('type', isEqualTo: 'Interest Revenue')
        .get();

    double tempTotal = 0.0;

    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;

      if (timestamp != null) {
        final docDate = timestamp.toDate(); // Convert Timestamp to DateTime

        // Check if the year and month of docDate match the current year and month
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          double total =
              (doc['total'] is num) ? (doc['total'] as num).toDouble() : 0;
          tempTotal += total;
        }
      }
    }

    setState(() {
      interestRevenueTotal = tempTotal;
    });
  }

  Future<void> interestExpense() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expensestracker')
        .where('type', isEqualTo: 'Interest Expense')
        .get();

    double tempTotal = 0.0;

    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;

      if (timestamp != null) {
        final docDate = timestamp.toDate(); // Convert Timestamp to DateTime

        // Check if the year and month of docDate match the current year and month
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          double total =
              (doc['total'] is num) ? (doc['total'] as num).toDouble() : 0;
          tempTotal += total;
        }
      }
    }

    setState(() {
      interestExpenseTotal = tempTotal;
    });
  }

  Future<void> nonOperatingIncome() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expensestracker')
        .where('type', isEqualTo: 'Non-Operating Income')
        .get();

    double tempTotal = 0.0;

    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;

      if (timestamp != null) {
        final docDate = timestamp.toDate(); // Convert Timestamp to DateTime

        // Check if the year and month of docDate match the current year and month
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          double total =
              (doc['total'] is num) ? (doc['total'] as num).toDouble() : 0;
          tempTotal += total;
        }
      }
    }

    setState(() {
      nonOperatingIncomeTotal = tempTotal;
    });
  }

  Future<void> expenseTotalCurrentMonth() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;

    // Check if the selected year is in the future
    if (currentYear! > DateTime.now().year) {
      setState(() {
        expenseTotalCurrentMonthTotal = 0.0;
      });
      return;
    }

    double tempTotal = 0.0;

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('expensestracker').get();

    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;
      if (timestamp != null) {
        final docDate = timestamp.toDate();
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          double total =
              (doc['total'] is num) ? (doc['total'] as num).toDouble() : 0.0;
          tempTotal += total;
        }
      }
    }

    // Ensure that tempTotal is a valid number (not NaN or Infinity)
    setState(() {
      expenseTotalCurrentMonthTotal = tempTotal.isFinite ? tempTotal : 0.0;
    });
  }

  double expenseTotalCurrentMonthTotalLastMonth = 0.0;
  Future<void> expenseTotalCurrentMonthLastMonth() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth - 1;

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('expensestracker').get();

    double tempTotal = 0.0;

    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;

      if (timestamp != null) {
        final docDate = timestamp.toDate(); // Convert Timestamp to DateTime

        // Check if the year and month of docDate match the current year and month
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          double total =
              (doc['total'] is num) ? (doc['total'] as num).toDouble() : 0.0;
          tempTotal += total;
        }
      }
    }

    // Update the state to refresh the UI
    setState(() {
      expenseTotalCurrentMonthTotalLastMonth = tempTotal;
    });
  }

  int endingInventory = 0;
  double restockPricePerUnitTotal =
      0.0; // Use double to maintain decimal precision
  int restockQuantityTotal = 0;
  Future<void> restockQuantity() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('expensestracker').get();

    int tempQuantity = 0;

    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;

      if (timestamp != null) {
        final docDate = timestamp.toDate(); // Convert Timestamp to DateTime

        // Check if the year and month of docDate match the current year and month
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          int quantity =
              (doc['quantity'] is num) ? (doc['quantity'] as num).toInt() : 0;
          tempQuantity += quantity;
        }
      }
    }

    // Update the state to refresh the UI
    setState(() {
      restockQuantityTotal = tempQuantity;
      restockPricePerUnitTotal =
          expenseTotalCurrentMonthTotal / restockQuantityTotal;
      endingInventory = restockQuantityTotal * restockPricePerUnitTotal.toInt();
    });
  }

  int operatingexpense = 0;
  Future<void> operatingexpenseData() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expensestracker')
        .where('type', isEqualTo: 'Operating Expense')
        .get();
    int tempQuantity = 0;
    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;
      if (timestamp != null) {
        final docDate = timestamp.toDate();
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          int total = (doc['total'] is num) ? (doc['total'] as num).toInt() : 0;
          tempQuantity += total;
        }
      }
    }
    setState(() {
      operatingexpense = tempQuantity;
    });
  }

  int administrativeexpense = 0;
  Future<void> administrativeexpenseData() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expensestracker')
        .where('type', isEqualTo: 'Administrative Expense')
        .get();
    int tempQuantity = 0;
    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;
      if (timestamp != null) {
        final docDate = timestamp.toDate();
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          int total = (doc['total'] is num) ? (doc['total'] as num).toInt() : 0;
          tempQuantity += total;
        }
      }
    }
    setState(() {
      administrativeexpense = tempQuantity;
    });
  }

  int marketingexpense = 0;
  Future<void> marketingexpenseData() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expensestracker')
        .where('type', isEqualTo: 'Marketing Expense')
        .get();
    int tempQuantity = 0;
    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;
      if (timestamp != null) {
        final docDate = timestamp.toDate();
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          int total = (doc['total'] is num) ? (doc['total'] as num).toInt() : 0;
          tempQuantity += total;
        }
      }
    }
    setState(() {
      marketingexpense = tempQuantity;
    });
  }

  int utilitiesexpense = 0;
  Future<void> utilitiesexpenseData() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expensestracker')
        .where('type', isEqualTo: 'Utilities Expense')
        .get();
    int tempQuantity = 0;
    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;
      if (timestamp != null) {
        final docDate = timestamp.toDate();
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          int total = (doc['total'] is num) ? (doc['total'] as num).toInt() : 0;
          tempQuantity += total;
        }
      }
    }
    setState(() {
      utilitiesexpense = tempQuantity;
    });
  }

  int maintenanceexpense = 0;
  int firstcardtotal = 0;
  Future<void> maintenanceexpenseData() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expensestracker')
        .where('type', isEqualTo: 'Maintenance Expense')
        .get();
    int tempQuantity = 0;
    for (var doc in querySnapshot.docs) {
      final timestamp = doc['date'] as Timestamp?;
      if (timestamp != null) {
        final docDate = timestamp.toDate();
        if (docDate.year == currentYear && docDate.month == currentMonth) {
          int total = (doc['total'] is num) ? (doc['total'] as num).toInt() : 0;
          tempQuantity += total;
        }
      }
    }
    setState(() {
      maintenanceexpense = tempQuantity;

      firstcardtotal = administrativeexpense +
          marketingexpense +
          utilitiesexpense +
          maintenanceexpense;

      restockQuantityLastMonth();
    });
  }

  Map<int, int> monthlyTotals = {};
  final List<String> monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  @override
  void initState() {
    super.initState();

    // Lock orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // Check for user authentication
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      context.go('/');
    }
    fetchData();
  }

  Future<void> fetchData() async {
    final now = DateTime.now();
    final currentYear = now.year;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('Receipts').get();

        if (querySnapshot.docs.isNotEmpty) {
          monthlyTotals = {for (var i = 1; i <= 12; i++) i: 0};

          final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS");
          for (var doc in querySnapshot.docs) {
            final dateString = doc['dateTimeCreated'] as String?;
            final userData = doc.data() as Map<String, dynamic>?;
            final docDate = dateFormat.parse(dateString!);
            if (docDate.year == currentYear) {
              if (userData != null && userData.containsKey('total')) {
                int amount = (userData['total'] as num?)?.toInt() ?? 0;

                String dateTimeCreated = userData['dateTimeCreated'] as String;
                DateTime createdDate = DateTime.parse(dateTimeCreated);

                monthlyTotals[createdDate.month] =
                    (monthlyTotals[createdDate.month] ?? 0) + amount;
              }
            }
          }

          setState(() {});
        } else {}
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  int beginningInventory = 0;
  double restockPricePerUnitTotalLastMonth = 0.0;
  double cogs = 0.0;
  double ebit = 0.0;
  double ebt = 0.0;
  double grossProfit = 0.0;
  double taxExpense = 0.0;
  double operatingIncome = 0.0;
  double netIncome = 0.0;
  int secondcardtotal = 0;
  int restockQuantityTotalLastMonth = 0;
  double grossProfitMargin = 0.0;
  double fourthcardtotal = 0.0;
  // Future<void> restockQuantityLastMonth() async {
  //   final currentYear = selectedYear;
  //   final currentMonth = selectedMonth - 1;

  //   QuerySnapshot querySnapshot =
  //       await FirebaseFirestore.instance.collection('expensestracker').get();

  //   int tempQuantity = 0;

  //   for (var doc in querySnapshot.docs) {
  //     final timestamp = doc['date'] as Timestamp?;

  //     if (timestamp != null) {
  //       final docDate = timestamp.toDate(); // Convert Timestamp to DateTime

  //       // Check if the year and month of docDate match the current year and month
  //       if (docDate.year == currentYear && docDate.month == currentMonth) {
  //         int quantity =
  //             (doc['quantity'] is num) ? (doc['quantity'] as num).toInt() : 0;
  //         tempQuantity += quantity;
  //       }
  //     }
  //   }

  //   // Ensure valid calculations and guard against NaN or Infinity
  //   double pricePerUnit = 0.0;
  //   if (restockQuantityTotalLastMonth > 0) {
  //     pricePerUnit = expenseTotalCurrentMonthTotalLastMonth /
  //         restockQuantityTotalLastMonth;
  //   }

  //   // Ensure valid calculations and guard against NaN or Infinity
  //   double beginningInventoryCalculated =
  //       restockQuantityTotalLastMonth * pricePerUnit;
  //   beginningInventoryCalculated = beginningInventoryCalculated.isFinite
  //       ? beginningInventoryCalculated
  //       : 0.0;

  //   double cogsCalculated =
  //       beginningInventoryCalculated + purchasesTotal + endingInventory;
  //   double grossProfitCalculated = monthlyTotal - cogsCalculated;
  //   double operatingIncomeCalculated =
  //       grossProfitCalculated - OperatingExpenseTotal;

  //   double ebitCalculated = operatingIncomeCalculated +
  //       nonOperatingIncomeTotal +
  //       nonOperatingExpenseTotal;

  //   double ebtCalculated =
  //       ebitCalculated + interestRevenueTotal + interestExpenseTotal;

  //   double taxExpenseCalculated = monthlyTotal * 0.12;
  //   double netIncomeCalculated = ebtCalculated - taxExpenseCalculated;

  //   // Update the state to refresh the UI with safe calculations
  //   setState(() {
  //     restockQuantityTotalLastMonth = tempQuantity;

  //     restockPricePerUnitTotalLastMonth = pricePerUnit.toInt().toDouble();
  //     beginningInventory = beginningInventoryCalculated.toInt();

  //     cogs = cogsCalculated;
  //     grossProfit = grossProfitCalculated;
  //     operatingIncome = operatingIncomeCalculated;

  //     ebit = ebitCalculated;
  //     ebt = ebtCalculated;
  //     taxExpense = taxExpenseCalculated;
  //     netIncome = netIncomeCalculated;

  //     secondcardtotal = (operatingIncomeCalculated +
  //             nonOperatingIncomeTotal +
  //             nonOperatingExpenseTotal)
  //         .toInt();

  //     grossProfitMargin = (grossProfit / monthlyTotal * 100).toInt();

  //     print('EBT: $ebt');
  //   });
  // }
  Future<void> restockQuantityLastMonth() async {
    final currentYear = selectedYear;
    final currentMonth = selectedMonth - 1;

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('expensestracker').get();

      int tempQuantity = 0;

      for (var doc in querySnapshot.docs) {
        final timestamp = doc['date'] as Timestamp?;
        if (timestamp != null) {
          final docDate = timestamp.toDate();
          if (docDate.year == currentYear && docDate.month == currentMonth) {
            tempQuantity +=
                (doc['quantity'] is num) ? (doc['quantity'] as num).toInt() : 0;
          }
        }
      }

      double pricePerUnit = tempQuantity > 0
          ? expenseTotalCurrentMonthTotalLastMonth / tempQuantity
          : 0.0;

      double beginningInventoryCalculated = tempQuantity * pricePerUnit;
      beginningInventoryCalculated = beginningInventoryCalculated.isFinite
          ? beginningInventoryCalculated
          : 0.0;

      double cogsCalculated =
          beginningInventoryCalculated + purchasesTotal + endingInventory;
      double grossProfitCalculated = monthlyTotal - cogsCalculated;
      double operatingIncomeCalculated =
          grossProfitCalculated - OperatingExpenseTotal;
      print('OperatingExpenseTotal: ${OperatingExpenseTotal}');
      print('operatingIncomeCalculated: ${operatingIncomeCalculated}');
      double ebitCalculated =
          fourthcardtotal + nonOperatingIncomeTotal - nonOperatingExpenseTotal;

      double ebtCalculated =
          ebitCalculated + interestRevenueTotal - interestExpenseTotal;

      double taxExpenseCalculated = monthlyTotal * 0.12;
      double netIncomeCalculated = ebtCalculated - totalvatistaxexpense;

      if (mounted) {
        setState(() {
          restockQuantityTotalLastMonth = tempQuantity;
          restockPricePerUnitTotalLastMonth = pricePerUnit;
          beginningInventory = beginningInventoryCalculated.toInt();
          cogs = cogsCalculated;
          grossProfit = grossProfitCalculated;
          operatingIncome = operatingIncomeCalculated;
          ebit = ebitCalculated;
          ebt = ebtCalculated;

          final formattedValue2 = NumberFormat.currency(
            locale: 'en_PH', // Use Philippine locale
            symbol: '₱', // Currency symbol
            decimalDigits: 2,
          ).format(ebtCalculated);
          taxExpense = taxExpenseCalculated;
          netIncome = netIncomeCalculated;
          secondcardtotal = (operatingIncomeCalculated +
                  nonOperatingIncomeTotal +
                  nonOperatingExpenseTotal)
              .toInt();
          grossProfitMargin = grossProfit.isFinite && monthlyTotal > 0
              ? (grossProfit / monthlyTotal * 100)
              : 0.0;

          fourthcardtotal = grossProfit - firstcardtotal;
          print(
              'fourthcardtotal: ${fourthcardtotal} = ${grossProfit} + ${firstcardtotal}');
          print('EBT: $ebt');
        });
      }
    } catch (e) {
      print('Error in restockQuantityLastMonth: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add your UI here

    List<FlSpot> spots = monthlyTotals.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
        .toList();

    final finalebt = NumberFormat.currency(
      locale: 'en_PH', // Use Philippine locale
      symbol: '₱', // Currency symbol
      decimalDigits: 2,
    ).format(ebt);

    final totalvatistaxexpense2 = NumberFormat.currency(
      locale: 'en_PH', // Use Philippine locale
      symbol: '₱', // Currency symbol
      decimalDigits: 2,
    ).format(totalvatistaxexpense);

    final firstcardtotal2 = NumberFormat.currency(
      locale: 'en_PH', // Use Philippine locale
      symbol: '₱', // Currency symbol
      decimalDigits: 2,
    ).format(firstcardtotal);

    final administrativeexpense2 = NumberFormat.currency(
      locale: 'en_PH', // Use Philippine locale
      symbol: '₱', // Currency symbol
      decimalDigits: 2,
    ).format(administrativeexpense);

    final marketingexpense2 = NumberFormat.currency(
      locale: 'en_PH', // Use Philippine locale
      symbol: '₱', // Currency symbol
      decimalDigits: 2,
    ).format(marketingexpense);

    final utilitiesexpense2 = NumberFormat.currency(
      locale: 'en_PH', // Use Philippine locale
      symbol: '₱', // Currency symbol
      decimalDigits: 2,
    ).format(utilitiesexpense);

    final maintenanceexpense2 = NumberFormat.currency(
      locale: 'en_PH', // Use Philippine locale
      symbol: '₱', // Currency symbol
      decimalDigits: 2,
    ).format(maintenanceexpense);

    final firstcardtotal3 = NumberFormat.currency(
      locale: 'en_PH', // Use Philippine locale
      symbol: '₱', // Currency symbol
      decimalDigits: 2,
    ).format(firstcardtotal);

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_PH', // Use Philippine locale
      symbol: '₱', // Currency symbol
      decimalDigits: 2,
    );

    final ebit3 = currencyFormatter.format(ebit);
    final fourthcardtotal3 = currencyFormatter.format(fourthcardtotal);
    final nonOperatingIncomeTotal3 =
        currencyFormatter.format(nonOperatingIncomeTotal);
    final nonOperatingExpenseTotal3 =
        currencyFormatter.format(nonOperatingExpenseTotal);
    final netIncome3 = currencyFormatter.format(netIncome);
    final totalvatistaxexpense3 =
        currencyFormatter.format(totalvatistaxexpense);
    final ebt3 = currencyFormatter.format(ebt);
    final monthlyTotal3 = currencyFormatter.format(monthlyTotal);
    final cogs3 = currencyFormatter.format(cogs);
    final grossProfit3 = currencyFormatter.format(grossProfit);
    final interestRevenueTotal3 =
        currencyFormatter.format(interestRevenueTotal);
    final interestExpenseTotal3 =
        currencyFormatter.format(interestExpenseTotal);

    final grossProfitMargin3 = NumberFormat.currency(
      locale: 'en_PH', // Use Philippine locale
      symbol: '', // Currency symbol
      decimalDigits: 2,
    ).format(grossProfitMargin);

    return WillPopScope(
      onWillPop: () async => false,
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
                unselectedIconColor: Colors.white,
                selectedIconColor: Colors.white,
                selectedColor: Color.fromRGBO(57, 181, 74, 1),
                backgroundColor: Color.fromRGBO(31, 29, 43, 1),
                displayMode: SideMenuDisplayMode.compact,
              ),
              items: [
                SideMenuItem(
                  icon: Icon(Icons.home),
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
              controller: SideMenuController(initialPage: 3),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 70,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Financial Report",
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 250.0,
                              color: Colors.white,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  value: selectedMonth,
                                  items: List.generate(12, (index) {
                                    return DropdownMenuItem<int>(
                                      value: index + 1,
                                      child: Text(months[index]),
                                    );
                                  }),
                                  onChanged: (newMonth) {
                                    setState(() {
                                      selectedMonth = newMonth!;
                                    });
                                    calculateTotals();
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Dropdown for selecting year
                            Container(
                              width: 250.0,
                              color: Colors.white,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  value: selectedYear,
                                  items: years.map((int year) {
                                    return DropdownMenuItem<int>(
                                      value: year,
                                      child: Text(year.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (newYear) {
                                    setState(() {
                                      selectedYear = newYear!;
                                    });
                                    calculateTotals();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(5),
                          child: AspectRatio(
                            aspectRatio: 2,
                            child: LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: spots,
                                    isCurved: true,
                                    dotData: const FlDotData(show: true),
                                    color: Colors.red,
                                    barWidth: 5,
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        // You can customize left titles here if needed
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(top: 8),
                                            child: Text(
                                              value
                                                  .toInt()
                                                  .toString(), // Change this to your desired label
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        String monthLabel = monthLabels[
                                            value.toInt() -
                                                1]; // Adjust for 0-indexing
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(top: 8),
                                            child: Text(
                                              monthLabel,
                                              style: const TextStyle(
                                                color: Colors
                                                    .black, // Set to black
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                    color: const Color(0xff37434d),
                                    width: 1,
                                  ),
                                ),
                                gridData: FlGridData(show: false),
                              ),
                            ),
                          ),
                        )),
                        Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            child: Row(
                              children: [
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 6,
                                    child: PieChart(
                                      PieChartData(
                                        sections: [
                                          PieChartSectionData(
                                            value: ebt.toDouble(),
                                            color: Colors.green,
                                            title: '',
                                            radius: 100,
                                          ),
                                          PieChartSectionData(
                                            value: taxExpense.toDouble(),
                                            color: Colors.red,
                                            title: '',
                                            radius: 100,
                                          ),
                                        ],
                                        borderData: FlBorderData(show: false),
                                        centerSpaceRadius: 0,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Column(
                                  children: [
                                    Text(
                                      'Income Before Tax',
                                      style: TextStyle(
                                          fontSize: 23,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      '${finalebt}',
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Text(
                                      'Tax Expense',
                                      style: TextStyle(
                                          fontSize: 23,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      '${totalvatistaxexpense2}',
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ))
                              ],
                            )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Container(
                                padding: EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width / 2.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Operating Expense:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Administrative Expense:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Marketing Expense:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Utilities Expense:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Maintenance Expense:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${firstcardtotal3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${administrativeexpense2}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${marketingexpense2}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${utilitiesexpense2}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${maintenanceexpense2}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${firstcardtotal2}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            SizedBox(height: 20),
                            Container(
                                padding: EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width / 2.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "EBIT:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Operating Income:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Non-Operating Income:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Non-Operating Expenses:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${ebit3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${fourthcardtotal3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${nonOperatingIncomeTotal3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${nonOperatingExpenseTotal3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${ebit3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            SizedBox(height: 20),
                            Container(
                                padding: EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width / 2.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Net Income:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "EBT:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Tax Expense:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${netIncome3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${ebt3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${totalvatistaxexpense3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${netIncome3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ))
                          ],
                        ),
                        SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Container(
                                padding: EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width / 2.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Operating Income:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Total Revenue:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "COGS:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Gross Profit:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Gross Profit Margin:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Operating Expenses:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${fourthcardtotal3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${monthlyTotal3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${cogs3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${grossProfit3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${grossProfitMargin3} %",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${firstcardtotal3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${fourthcardtotal3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            SizedBox(height: 20),
                            Container(
                                padding: EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width / 2.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "EBT:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "EBIT:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Interest Revenue:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Interest Expenses:",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${ebt3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${ebit3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${interestRevenueTotal3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${interestExpenseTotal3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${ebt3}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            SizedBox(height: 20),
                            Container(
                                padding: EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width / 2.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Net Income",
                                          style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "${netIncome3}",
                                          style: TextStyle(
                                              fontSize: 50,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
