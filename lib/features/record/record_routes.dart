// lib/features/record/record_routes.dart
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/features/record/schedule_create_screen.dart';
import 'package:heat_trip_flutter/features/record/schedule_list_screen.dart';

final List<RouteBase> recordRoutes = [
  GoRoute(
    path: '/record',
    name: 'record',
    builder: (context, state) => const ScheduleListScreen(),
    routes: [
      GoRoute(
        path: 'create',
        name: 'scheduleCreate',
        builder: (context, state) => const ScheduleCreateScreen(),
      ),
    ],
  ),
];
