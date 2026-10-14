import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  final mailController = TextEditingController();
  final passwordContorller = TextEditingController();
  final auth = FirebaseAuth.instance;
  Future<void> login() async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: mailController.text.trim(),
        password: passwordContorller.text,
      );

      print('Login successful: ${userCredential.user?.email}');
      context.pushReplacement('./home');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
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
    // TODO: implement build
    return (Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'LOGIN',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                ),
                SizedBox(height: 20),

                Padding(
                  padding: EdgeInsetsGeometry.all(10),
                  child: TextField(
                    controller: mailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your mail id',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.all(10),
                  child: TextField(
                    controller: passwordContorller,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your password',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  child: Text('Submit'),
                ),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    context.go('/signup');
                  },
                  child: Text('Don\'t have account? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
