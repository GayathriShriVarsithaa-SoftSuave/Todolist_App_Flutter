import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeScreen();
  }
}

class _HomeScreen extends State<HomeScreen> {
  final searchcontroller = TextEditingController();
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: AlignmentGeometry.topLeft,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsGeometry.all(10),
                          child: TextField(
                            controller: searchcontroller,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: 'Search Tasks..',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          logout();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.red),
                        ),
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Add task clicked');
        },
        child: Icon(Icons.add),
      ),
    ));
  }
}
