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
    const backgroundColor = Color(0xFF0F172A);
    const foregroundColor = Color(0xFFE9DDFF);

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
                    color: foregroundColor,
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: mailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: foregroundColor),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.mail_outline,
                        color: foregroundColor,
                      ),
                      hintText: 'Enter your mail id',
                      hintStyle: TextStyle(
                        color: foregroundColor.withValues(alpha: 0.65),
                      ),
                      filled: true,
                      fillColor: foregroundColor.withValues(alpha: 0.05),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: foregroundColor),
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
                    style: TextStyle(color: foregroundColor),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: foregroundColor,
                      ),
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(
                        color: foregroundColor.withValues(alpha: 0.65),
                      ),
                      filled: true,
                      fillColor: foregroundColor.withValues(alpha: 0.05),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: foregroundColor),
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
                      style: TextStyle(color: foregroundColor, fontSize: 14),
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
