// lib/features/profile/profile_routes.dart
import 'package:go_router/go_router.dart';
import 'presentation/screens/profile_screen.dart';
import 'expense_history_screen.dart';

final List<RouteBase> profileRoutes = [
  GoRoute(
    path: '/profile',
    name: 'profile',
    builder: (context, state) => const ProfileScreen(),
    routes: [
      GoRoute(
        path: 'expense-history',
        name: 'expenseHistory',
        builder: (context, state) => const ExpenseHistoryScreen(),
      ),
    ],
  ),
];
