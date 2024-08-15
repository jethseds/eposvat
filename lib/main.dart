import 'package:flutter/material.dart';
import 'package:posadmin/app/app.dart';
import 'package:posadmin/bootstrap.dart';
import 'package:posadmin/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  bootstrap(() => const App());
}
