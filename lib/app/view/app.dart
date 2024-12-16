import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posadmin/counter/view/add_product_page.dart';
import 'package:posadmin/counter/view/edit_product_page.dart';
import 'package:posadmin/counter/view/expense_tracker.dart';
import 'package:posadmin/counter/view/expense_tracker_form.dart';
import 'package:posadmin/counter/view/expense_tracker_form_edit.dart';
import 'package:posadmin/counter/view/expenses_page.dart';
import 'package:posadmin/counter/view/financial_report.dart';
import 'package:posadmin/counter/view/inventory_page.dart';
import 'package:posadmin/counter/view/login_page.dart';
import 'package:posadmin/counter/view/pos_page.dart';
import 'package:posadmin/counter/view/qr_scanner.dart';
import 'package:posadmin/l10n/l10n.dart';

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return LoginPage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'pos',
          builder: (BuildContext context, GoRouterState state) {
            return PosPage();
          },
        ),
        GoRoute(
          path: 'expenses',
          builder: (BuildContext context, GoRouterState state) {
            return ExpensesPage();
          },
        ),

        GoRoute(
          path: 'inventory',
          builder: (BuildContext context, GoRouterState state) {
            return InventoryPage();
          },
        ),
        GoRoute(
          path: 'financialreport',
          builder: (BuildContext context, GoRouterState state) {
            return FinancialReport();
          },
        ),
        GoRoute(
          path: 'expensetracker',
          builder: (BuildContext context, GoRouterState state) {
            return ExpenseTrackerPage();
          },
        ),
        GoRoute(
          path: 'expensetrackerform',
          builder: (BuildContext context, GoRouterState state) {
            return ExpenseTrackerForm();
          },
        ),
        GoRoute(
          path: 'expensetrackerformedit/:docID',
          builder: (BuildContext context, GoRouterState state) {
            return ExpenseTrackerFormEdit(
              docID: state.pathParameters['docID']!,
            );
          },
        ),
        GoRoute(
          path: 'add',
          builder: (BuildContext context, GoRouterState state) {
            return AddProductPage();
          },
        ),
        GoRoute(
          path: 'scanner',
          builder: (BuildContext context, GoRouterState state) {
            return MyHome();
          },
        ),
        GoRoute(
          path: 'edit/:code',
          builder: (BuildContext context, GoRouterState state) {
            return EditProductPage(
              code: int.parse(state.pathParameters['code']!),
            );
          },
        ),
        // GoRoute(
        //   path: 'receipt/:referenceNumber',
        //   builder: (BuildContext context, GoRouterState state) {
        //     return ReceiptPage(
        //       referenceNumber:
        //           int.parse(state.pathParameters['referenceNumber']!),
        //     );
        //   },
        // ),
      ],
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        textTheme: TextTheme(
          bodySmall: TextStyle(),
          bodyMedium: TextStyle(),
          bodyLarge: TextStyle(),
        ).apply(bodyColor: Colors.white),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
