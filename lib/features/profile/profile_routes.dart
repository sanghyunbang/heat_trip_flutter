// lib/features/profile/profile_routes.dart
//
// 목적
// - go_router 중첩 규칙에 맞게 자식 경로를 'edit'로 설정(앞에 '/'를 붙이지 않음). [④]
// - 부모 /profile 아래로 /profile/edit 완성.
//
// 주의
// - 자식 경로에서 '/'로 시작하면 절대 경로가 되어 중첩이 깨집니다.

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
        path: 'edit', // ← 슬래시 제거! 부모 '/profile' + 'edit' = '/profile/edit' [④]
        builder: (context, state) => const ProfileEditScreen(),
      ),
    ],
  ),
];

/* ─────────────────────────── 각주 ───────────────────────────
[④] go_router의 중첩 경로 규칙: 자식은 슬래시 없이 상대 경로여야
     부모 path와 결합됩니다. ('/profile' + 'edit' = '/profile/edit')
────────────────────────────────────────────────────────── */
