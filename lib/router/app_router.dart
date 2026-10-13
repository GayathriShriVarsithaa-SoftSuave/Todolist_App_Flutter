import 'package:go_router/go_router.dart';

import './../Screens/auth/loginScreen.dart';

import './../Screens/auth/signUpScreen.dart';

import './../Screens/homeScreen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
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