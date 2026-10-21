import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import './../../../services/toast_msg.dart';

import 'package:firebase_auth/firebase_auth.dart';

import './auth_services.dart';

import 'package:go_router/go_router.dart';

Future<void> signup(
  BuildContext context,
  TextEditingController passwordcontroller,
  TextEditingController mailcontroller,
  TextEditingController conformpasswordcontroller,
) async {
  final AuthServices authServices = AuthServices();
  final bool showToaster =
      !passwordcontroller.text.trim().contains(RegExp(r'[A-Z]')) ||
      !passwordcontroller.text.trim().contains(RegExp(r'[a-z]')) ||
      !passwordcontroller.text.trim().contains(RegExp(r'[0-9]')) ||
      !passwordcontroller.text.trim().contains(
        RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]'),
      );

  if (mailcontroller.text.trim().isEmpty ||
      passwordcontroller.text.trim().isEmpty ||
      conformpasswordcontroller.text.trim().isEmpty) {
    showToastMsg(
      'Enter all fields',
      Colors.deepOrangeAccent,
      Toast.LENGTH_SHORT,
    );
    return;
  }
  if (passwordcontroller.text != conformpasswordcontroller.text) {
    showToastMsg(
      'Passwords do not match',
      Colors.deepOrangeAccent,
      Toast.LENGTH_SHORT,
    );
    return;
  }
  if (!mailcontroller.text.trim().contains('@')) {
    showToastMsg(
      'Not a valid Mail',
      Colors.deepOrangeAccent,
      Toast.LENGTH_SHORT,
    );
    return;
  }
  if (passwordcontroller.text.trim().length < 6) {
    showToastMsg(
      'Minimum password length must be 6 characters',
      Colors.deepOrangeAccent,
      Toast.LENGTH_SHORT,
    );
    return;
  }
  if (showToaster) {
    showToastMsg(
      'Password must atleast contain 1 uppercase, 1 lowercase, 1 number and 1 special character',
      Colors.deepOrangeAccent,
      Toast.LENGTH_SHORT,
    );
    return;
  }

  try {
    final userCredential = await authServices.signup(
      email: mailcontroller.text,
      password: passwordcontroller.text,
    );

    if (!context.mounted) return;

    if (userCredential.user != null) {
      print('Signup successful: ${userCredential.user?.email}');
      print('UID: ${userCredential.user?.uid}');

      context.go('/home');
    }
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return;
    showToastMsg(e.message ?? 'Sign up failed', Colors.red, Toast.LENGTH_LONG);
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

    context.go('/home');
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
