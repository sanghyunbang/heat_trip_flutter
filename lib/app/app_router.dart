// // lib/app/app_router.dart
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// // 탭 루트들
// import 'package:heat_trip_flutter/features/explore/presentation/screens/explore_screen.dart';
// import 'package:heat_trip_flutter/features/profile/expense_history_screen.dart';
// import 'package:heat_trip_flutter/features/record/schedule_create_screen.dart';
// import 'package:heat_trip_flutter/features/record/schedule_list_screen.dart';
// import 'package:heat_trip_flutter/features/journey/presentation/screens/journey_screen.dart';
// import 'package:heat_trip_flutter/features/profile/presentation/screens/profile_screen.dart';
// import 'package:heat_trip_flutter/features/auth/presentation/login_screen.dart';

// // 큐레이션 (감정 선택)
// import 'package:heat_trip_flutter/features/curation/presentation/screens/curation_screen.dart';
// import 'package:heat_trip_flutter/features/curation/presentation/screens/curation_result_screen.dart';

// // 온보딩/인증
// import 'package:heat_trip_flutter/features/auth/presentation/sign_up_screen.dart';
// import 'package:heat_trip_flutter/features/start/start_screen.dart'; // 아래 리팩토링한 StartScreen 경로

// // 탭 쉘(바텀바+FAB) UI
// import 'package:heat_trip_flutter/core/widgets/layout/main_nav_shell.dart';

// final GoRouter appRouter = GoRouter(
//   // 앱을 켜면 먼저 온보딩으로 진입
//   initialLocation: '/start',
//   routes: [
//     // Start (탭 밖)
//     GoRoute(
//       path: '/start',
//       name: 'start',
//       builder: (context, state) => const StartScreen(),
//     ),

//     // SignUp (탭 밖)
//     GoRoute(
//       path: '/auth/sign-up',
//       name: 'signUp',
//       builder: (context, state) => SignUpScreen(),
//     ),

//     // 로그인 추가
//     GoRoute(
//       path: '/auth/login',
//       name: 'login',
//       builder: (context, state) => const LoginScreen(),
//     ),

//     // 탭 전역 (탭 안에서만 돌아다님)
//     StatefulShellRoute.indexedStack(
//       builder: (context, state, navigationShell) =>
//           MainNavShell(navigationShell: navigationShell),
//       branches: [
//         StatefulShellBranch(
//           routes: [
//             GoRoute(
//               path: '/explore',
//               name: 'explore',
//               builder: (context, state) => const ExploreScreen(),
//             ),
//           ],
//         ),

//         StatefulShellBranch(
//           routes: [
//             GoRoute(
//               path: '/record',
//               name: 'record',
//               builder: (context, state) => const ScheduleListScreen(),
//               routes: [
//                 // ✅ 작성 화면 (하위 라우트)
//                 GoRoute(
//                   path: 'create',
//                   name: 'scheduleCreate',
//                   builder: (context, state) => const ScheduleCreateScreen(),
//                 ),
//               ],
//             ),
//           ],
//         ),

//         StatefulShellBranch(
//           routes: [
//             GoRoute(
//               path: '/curation',
//               name: 'curation',
//               builder: (context, state) => const CurationScreen(),
//               routes: [
//                 GoRoute(
//                   path: 'result',
//                   name: 'curationResult',
//                   builder: (context, state) => const CurationResultScreen(),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         StatefulShellBranch(
//           routes: [
//             GoRoute(
//               path: '/journey',
//               name: 'journey',
//               builder: (context, state) => const JourneyScreen(),
//             ),
//           ],
//         ),
//         StatefulShellBranch(
//           routes: [
//             GoRoute(
//               path: '/profile',
//               name: 'profile',
//               builder: (context, state) => const ProfileScreen(),
//               routes: [
//                 // ✅ 프로필 상세: 지출 내역
//                 GoRoute(
//                   path: 'expense-history',
//                   name: 'expenseHistory',
//                   builder: (context, state) => const ExpenseHistoryScreen(),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     ),
//   ],
// );

// lib/app/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/core/widgets/layout/main_nav_shell.dart';
import 'package:heat_trip_flutter/features/foryou/foryou_route.dart';

// feature routes
import 'package:heat_trip_flutter/features/start/start_routes.dart';
import 'package:heat_trip_flutter/features/auth/auth_routes.dart';
import 'package:heat_trip_flutter/features/explore/explore_routes.dart';
import 'package:heat_trip_flutter/features/record/record_routes.dart';
import 'package:heat_trip_flutter/features/curation/curation_routes.dart';
import 'package:heat_trip_flutter/features/journey/journey_routes.dart';
import 'package:heat_trip_flutter/features/profile/profile_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/start',
  routes: [
    ...startRoutes, // 탭 밖
    ...authRoutes, // 탭 밖
    // 탭 전역(바텀바/FAB가 들어있는 쉘)
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainNavShell(navigationShell: shell),
      branches: [
        // 함수 호출로 받아온다 (env 로드 이후 시점)
        StatefulShellBranch(routes: buildExploreRoutes()),
        StatefulShellBranch(routes: recordRoutes),
        StatefulShellBranch(
          routes: foryouRoutes,
        ), // foryouRoutes 추가[curationRoutes → foryouRoutes]
        StatefulShellBranch(routes: journeyRoutes),
        StatefulShellBranch(routes: profileRoutes),
      ],
    ),
  ],
);
