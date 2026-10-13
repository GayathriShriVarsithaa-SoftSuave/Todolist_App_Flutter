import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todolist_app/screens/homeScreen.dart';

import './firebase_options.dart';
import 'screens/auth/loginScreen.dart';

import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final auth = FirebaseAuth.instance;
  runApp(
    MaterialApp(home: auth.currentUser != null ? HomeScreen() : LoginPage()),
  );
}
