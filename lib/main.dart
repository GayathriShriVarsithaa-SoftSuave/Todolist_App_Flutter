import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todolist_app/core/router/app_router.dart';
import 'package:todolist_app/core/features/home/screen/homeScreen.dart';

import 'core/firebase/firebase_options.dart';
import 'core/features/auth/screens/loginScreen.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'core/providers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();
  final auth = FirebaseAuth.instance;
  runApp(
    MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    ),
  );
}
