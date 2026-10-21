import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import './toast_msg.dart';

Future<void> logout() async {
  await FirebaseAuth.instance.signOut();
  showToastMsg('logged out', Colors.green, Toast.LENGTH_LONG);
}
