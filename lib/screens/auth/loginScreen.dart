import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return (Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: TextField(
                
              ),
            ),
            Expanded(child: TextField()),
            GestureDetector(
              onTap: () {
                
              },
              child: Text('Don\'t have account? Sign Up'),
            )
          ],
        )
      ),
    ));
  }
}
