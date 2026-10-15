import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> signup() async {
    final auth = FirebaseAuth.instance;

    if (passwordcontroller.text != conformpasswordcontroller.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
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

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Sign up failed')));
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
                  'SIGN UP',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                ),
                SizedBox(height: 20),

                Padding(
                  padding: EdgeInsetsGeometry.all(10),
                  child: TextField(
                    controller: mailcontroller,
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
                    controller: passwordcontroller,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      hintText: 'Enter your password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                  padding: EdgeInsetsGeometry.all(10),
                  child: TextField(
                    controller: conformpasswordcontroller,
                    obscureText: !isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      hintText: 'Confirm password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                ElevatedButton(
                  onPressed: () {
                    signup();
                  },
                  child: Text('Submit'),
                ),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    context.pushReplacement('/login');
                  },
                  child: Text('Already have an account?'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
