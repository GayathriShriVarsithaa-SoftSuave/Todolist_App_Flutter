import 'package:flutter/material.dart';

import './../../../services/toast_msg.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './auth_services.dart';

Future<void> login(
  TextEditingController mailController,
  TextEditingController passwordContorller,
) async {
  final AuthServices authServices = AuthServices();
  if (mailController.text.trim().isEmpty ||
      passwordContorller.text.trim().isEmpty) {
    showToastMsg(
      'Enter all fields',
      Colors.deepOrangeAccent,
      Toast.LENGTH_SHORT,
    );
    return;
  }
  if (!mailController.text.trim().contains('@')) {
    showToastMsg(
      'Not a valid Mail',
      Colors.deepOrangeAccent,
      Toast.LENGTH_SHORT,
    );
    return;
  }
  try {
    final userCredential = await authServices.login(
      email: mailController.text,
      password: passwordContorller.text,
    );

    print('Login successful: ${userCredential.user?.email}');
  } on FirebaseAuthException catch (e) {
    showToastMsg(e.message ?? 'Login failed', Colors.red, Toast.LENGTH_LONG);
  }
}


Future<void> signInWithGoogle(BuildContext context) async {
  final AuthServices authServices = AuthServices();
    try {
      final userCredential = await authServices.signInWithGoogle();
      if (!context.mounted) return;
      showToastMsg('Signed In', Colors.green, Toast.LENGTH_LONG);
      print('Google sign-in successful');
      print('Email: ${userCredential.user?.email}');
      print('UID: ${userCredential.user?.uid}');
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      showToastMsg(
        e.message ?? 'Google sign-in failed',
        Colors.red,
        Toast.LENGTH_LONG,
      );
    } catch (e) {
      if (!context.mounted) return;
      showToastMsg('Google sign-in failed: $e', Colors.red, Toast.LENGTH_LONG);
    }
  }