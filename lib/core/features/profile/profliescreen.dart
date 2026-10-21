import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProfileScreen();
  }
}

class _ProfileScreen extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    const backgroundColor = Color.fromRGBO(13, 43, 29, 1);
    const foregroundColor = Color.fromRGBO(0, 230, 118, 1);
    const textColor = Color.fromRGBO(255, 255, 255, 1);
    final String? email = FirebaseAuth.instance.currentUser?.email;

    // TODO: implement build
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, color: textColor, size: 200),
              Text(
                'Email: $email',
                style: TextStyle(color: textColor, fontSize: 25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
