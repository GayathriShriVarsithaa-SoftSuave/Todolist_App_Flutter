import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToastMsg(String message, Color bgcolor, Toast length) {
  Fluttertoast.showToast(
    msg: message,
    toastLength:length,
    gravity: ToastGravity.TOP,
    backgroundColor:bgcolor,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}