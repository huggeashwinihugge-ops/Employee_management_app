import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase initialized ONLY ONCE (safe & correct)
  await Firebase.initializeApp();

  runApp(const MyApp());
}
