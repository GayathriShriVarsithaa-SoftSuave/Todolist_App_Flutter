import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import './../services/auth_services.dart';
import './../../../services/toast_msg.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  final AuthServices authServices = AuthServices();
  final mailController = TextEditingController();
  final passwordContorller = TextEditingController();
  bool ispasswordVisible = false;

  Future<void> signInWithGoogle() async {
    try {
      final userCredential = await authServices.signInWithGoogle();
      if (!mounted) return;
      showToastMsg('Signed In', Colors.green, Toast.LENGTH_LONG);
      print('Google sign-in successful');
      print('Email: ${userCredential.user?.email}');
      print('UID: ${userCredential.user?.uid}');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showToastMsg(
        e.message ?? 'Google sign-in failed',
        Colors.red,
        Toast.LENGTH_LONG,
      );
    } catch (e) {
      if (!mounted) return;
      showToastMsg('Google sign-in failed: $e', Colors.red, Toast.LENGTH_LONG);
    }
  }

  Future<void> login() async {
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

  @override
  void dispose() {
    mailController.dispose();
    passwordContorller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color.fromRGBO(13, 43, 29, 1);
    const foregroundColor = Color.fromRGBO(0, 230, 118, 1);
    const textColor = Color.fromRGBO(255, 255, 255, 1);
    const cardColor = Color.fromRGBO(22, 61, 43, 1);
    const borderColor = Color.fromRGBO(45, 90, 67, 1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'LOGIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: mailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.mail_outline,
                        color: foregroundColor,
                      ),
                      hintText: 'Enter your mail id',
                      hintStyle: TextStyle(color: textColor),
                      filled: true,
                      fillColor: cardColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: foregroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: passwordContorller,
                    obscureText: !ispasswordVisible,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: foregroundColor,
                      ),
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: textColor),
                      filled: true,
                      fillColor: cardColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: foregroundColor,
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          ispasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: foregroundColor,
                        ),
                        onPressed: () {
                          setState(() {
                            ispasswordVisible = !ispasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: OutlinedButton.icon(
                    onPressed: signInWithGoogle,
                    icon: Icon(Icons.login, color: foregroundColor),
                    label: Text(
                      'Sign in with Google',
                      style: TextStyle(color: foregroundColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: foregroundColor),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: foregroundColor,
                      foregroundColor: backgroundColor,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      context.go('/signup');
                    },
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: textColor, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
