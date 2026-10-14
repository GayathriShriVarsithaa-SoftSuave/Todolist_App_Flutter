import 'package:go_router/go_router.dart';

import './../screens/auth/loginScreen.dart';

import './../screens/auth/signUpScreen.dart';

import './../screens/homeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<User?> _subscription;
  AuthNotifier() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      notifyListeners();
    });
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final authNotifier = AuthNotifier();


final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: authNotifier,
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;

    final isLoginPage = state.matchedLocation == '/login';
    final isSignupPage = state.matchedLocation == '/signup';

    if (user == null && !isLoginPage && !isSignupPage) {
      return '/login';
    }

    if (user != null && (isLoginPage || isSignupPage)) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignUpPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
    ),
  ],
);