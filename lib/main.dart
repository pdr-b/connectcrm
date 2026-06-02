import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/connect_crm_app.dart';
import 'firebase_options.dart';
 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? firebaseError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    firebaseError = error;
  }

  runApp(ConnectCrmApp(firebaseError: firebaseError));
}
