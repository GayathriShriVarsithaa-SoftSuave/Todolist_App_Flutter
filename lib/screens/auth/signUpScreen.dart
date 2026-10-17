import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SignUpPage();
  }
}

class _SignUpPage extends State<SignUpPage> {
  final mailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final conformpasswordcontroller = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

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

      Fluttertoast.showToast(
        msg: e.message ?? 'Google sign-in failed',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'Google sign-in failed: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> signup() async {
    final auth = FirebaseAuth.instance;
    if (mailcontroller.text.trim().isEmpty ||
        passwordcontroller.text.trim().isEmpty ||
        conformpasswordcontroller.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: 'Enter all fields',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    if (passwordcontroller.text != conformpasswordcontroller.text) {
      Fluttertoast.showToast(
        msg: 'Passwords do not match',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    if (!mailcontroller.text.trim().contains('@')) {
      Fluttertoast.showToast(
        msg: 'Not a valid Mail',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    if (passwordcontroller.text.trim().length < 6) {
      Fluttertoast.showToast(
        msg: 'Minimum password length must be 6 characters',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    if (!passwordcontroller.text.trim().contains(RegExp(r'[A-Z]'))) {
      Fluttertoast.showToast(
        msg: 'Password must atleast contain 1 uppercase',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    if (!passwordcontroller.text.trim().contains(RegExp(r'[a-z]'))) {
      Fluttertoast.showToast(
        msg: 'Password must atleast contain 1 lowercase',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    if (!passwordcontroller.text.trim().contains(RegExp(r'[0-9]'))) {
      Fluttertoast.showToast(
        msg: 'Password must atleast contain 1 number',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    if (!passwordcontroller.text.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]'),
    )) {
      Fluttertoast.showToast(
        msg: 'Password must contain at least 1 special character',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: mailcontroller.text.trim(),
        password: passwordcontroller.text,
      );

      if (!mounted) return;

      if (userCredential.user != null) {
        print(UserCredential);
        context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: e.message ?? 'Sign up failed',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  void dispose() {
    mailcontroller.dispose();
    passwordcontroller.dispose();
    conformpasswordcontroller.dispose();
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
                  'SIGN UP',
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
                    controller: mailcontroller,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: backgroundColor),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.mail_outline,
                        color: backgroundColor,
                      ),
                      hintText: 'Enter your mail id',
                      hintStyle: TextStyle(color: backgroundColor),
                      filled: true,
                      fillColor: foregroundColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: backgroundColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: backgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: passwordcontroller,
                    obscureText: !isPasswordVisible,
                    style: TextStyle(color: backgroundColor),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: backgroundColor,
                      ),
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: backgroundColor),
                      filled: true,
                      fillColor: foregroundColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: backgroundColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: backgroundColor,
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: backgroundColor,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: conformpasswordcontroller,
                    obscureText: !isConfirmPasswordVisible,
                    style: TextStyle(color: backgroundColor),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: backgroundColor,
                      ),
                      hintText: 'Confirm password',
                      hintStyle: TextStyle(color: backgroundColor),
                      filled: true,
                      fillColor: foregroundColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: backgroundColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: backgroundColor,
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: backgroundColor,
                        ),
                        onPressed: () {
                          setState(() {
                            isConfirmPasswordVisible =
                                !isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 30),
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
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: ElevatedButton(
                    onPressed: signup,
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
                      context.pushReplacement('/login');
                    },
                    child: Text(
                      'Already have an account? Login',
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
