import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/core/widgets/layout/main_nav_shell.dart';

// tabs
import 'package:heat_trip_flutter/features/start/start_routes.dart';
import 'package:heat_trip_flutter/features/auth/auth_routes.dart';
import 'package:heat_trip_flutter/features/explore/explore_routes.dart';
import 'package:heat_trip_flutter/features/record/record_routes.dart';
import 'package:heat_trip_flutter/features/journey/journey_routes.dart';
import 'package:heat_trip_flutter/features/profile/profile_routes.dart';

// ✅ 새로 추가
import 'package:heat_trip_flutter/features/foryou/foryou_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/start',
  routes: [
    ...startRoutes,
    ...authRoutes,
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainNavShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: buildExploreRoutes()),
        StatefulShellBranch(routes: recordRoutes),
        // ✅ 기존 curation 브랜치 → foryou로 대체
        StatefulShellBranch(routes: forYouRoutes),
        StatefulShellBranch(routes: journeyRoutes),
        StatefulShellBranch(routes: profileRoutes),
      ],
    ),
  ],
);
