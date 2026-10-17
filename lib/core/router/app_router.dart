import 'package:go_router/go_router.dart';

import '../features/auth/screens/loginScreen.dart';

import '../features/auth/screens/signUpScreen.dart';

import '../features/home/homeScreen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
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
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => SignUpPage()),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final uid = FirebaseAuth.instance.currentUser?.uid;

        if (uid == null) {
          return LoginPage();
        }

        return ChangeNotifierProvider(
          key: ValueKey(uid),
          create: (_) => TaskProvider(),
          child: HomeScreen(),
        );
      },
    ),
  ],
);
