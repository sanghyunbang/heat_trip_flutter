import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/features/start/start_screen.dart';

final List<RouteBase> startRoutes = [
  GoRoute(
    path: '/start',
    name: 'start',
    builder: (_, __) => const StartScreen(),
  ),
];
