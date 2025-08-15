// lib/features/auth/auth_routes.dart
import 'package:go_router/go_router.dart';
import 'presentation/login_screen.dart';
import 'presentation/sign_up_screen.dart';

final List<RouteBase> authRoutes = [
  GoRoute(
    path: '/auth/login',
    name: 'login',
    builder: (_, __) => const LoginScreen(),
  ),
  GoRoute(
    path: '/auth/sign-up',
    name: 'signUp',
    builder: (_, __) => SignUpScreen(),
  ),
];
