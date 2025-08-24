// lib/features/profile/profile_routes.dart
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/features/profile/presentation/screens/profile_edit_screen.dart';
import 'presentation/screens/profile_screen.dart';

final List<RouteBase> profileRoutes = [
  GoRoute(
    path: '/profile',
    name: 'profile',
    builder: (context, state) => const ProfileScreen(),
    routes: [
      GoRoute(
        name: 'profileEdit',
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
    ],
  ),
];
