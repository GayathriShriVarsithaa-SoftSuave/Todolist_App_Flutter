import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool ispasswordVisible = false;

  Future<void> signInWithGoogle() async {
    try {
      // 1. Open Google account selection
      final googleUser = await GoogleSignIn.instance.authenticate();

      // 2. Get the Google authentication token
      final googleAuth = googleUser.authentication;

      // 3. Create Firebase credential using Google's ID token
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      print('Google sign-in successful');
      print('Email: ${userCredential.user?.email}');
      print('UID: ${userCredential.user?.uid}');

      // Your existing GoRouter auth listener should
      // redirect the authenticated user to /home.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Google sign-in failed')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    }
  }

  Future<void> login() async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: mailController.text.trim(),
        password: passwordContorller.text,
      );
      print(userCredential);
      print('Login successful: ${userCredential.user?.email}');
      print('uid:${userCredential.user?.uid}');
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
                      prefixIcon: Icon(Icons.mail),
                      border: OutlineInputBorder(),
                      hintText: 'Enter your mail id',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.all(10),
                  child: TextField(
                    controller: passwordContorller,
                    obscureText: !ispasswordVisible,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      hintText: 'Enter your password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          ispasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                OutlinedButton.icon(
                  onPressed: signInWithGoogle,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                ),
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
