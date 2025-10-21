// lib/app/app_router.dart
//
// 목적:
// - 전역 라우터 + 인증 가드.
// - 미로그인일 때 보호 경로 접근 → /auth/login 로만 막고,
//   그 외엔 리다이렉트 최소화(로그인 화면 접속을 방해하지 않음).
//
// 핵심 변경점:
// [R1] "로그인 상태에서 /auth/* 접근 → 메인으로 강제" 규칙 제거
// [R2] 미로그인 + 보호경로 접근일 때만 /auth/login 으로 보냄
// [R3] 로그인 성공 후 어디로 갈지는 화면(로그인/회원가입)에서 context.go()로 명시 처리

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:heat_trip_flutter/features/auth/state/auth_state.dart';
import 'package:heat_trip_flutter/core/widgets/layout/main_nav_shell.dart';

// 라우트 묶음들
import 'package:heat_trip_flutter/features/start/start_routes.dart';
import 'package:heat_trip_flutter/features/auth/auth_routes.dart';
import 'package:heat_trip_flutter/features/explore/explore_routes.dart';
import 'package:heat_trip_flutter/features/record/record_routes.dart';
import 'package:heat_trip_flutter/features/journey/journey_routes.dart';
import 'package:heat_trip_flutter/features/profile/profile_routes.dart';
import 'package:heat_trip_flutter/features/bookmark/bookmark_routes.dart';
import 'package:heat_trip_flutter/features/foryou_v2/routes.dart';

/// 로그인 이후 기본 탭
const String MAIN_AFTER_LOGIN = '/foryou_v2';

GoRouter buildAppRouter({required Listenable refreshListenable}) {
  final Listenable authListenable = refreshListenable;

  bool _isLoggedIn() =>
      authListenable is AuthState ? authListenable.loggedIn : false;

  bool _isAuthPath(String path) => path.startsWith('/auth');
  bool _isStartPath(String path) => path.startsWith('/start');
  bool _isPublic(String path) => _isAuthPath(path) || _isStartPath(path);

  return GoRouter(
    initialLocation: '/start',
    refreshListenable: authListenable,
    routes: [
      ...authRoutes,   // /auth/*
      ...startRoutes,  // /start
      StatefulShellRoute.indexedStack(
        builder: (context, state, navShell) =>
            MainNavShell(navigationShell: navShell),
        branches: [
          StatefulShellBranch(routes: buildExploreRoutes()),
          StatefulShellBranch(routes: recordRoutes),
          StatefulShellBranch(routes: forYouV2Routes),
          StatefulShellBranch(routes: journeyRoutes),
          StatefulShellBranch(routes: [...profileRoutes, ...bookmarkRoutes]),
        ],
      ),
    ],
    redirect: (context, state) {
      final loggedIn = _isLoggedIn();
      final goingTo = state.matchedLocation;

      // [R2] 미로그인 + 보호 경로 → 로그인 페이지로만 리다이렉트
      if (!loggedIn && !_isPublic(goingTo)) {
        return '/auth/login';
      }

      // [R1] 로그인 상태에서 /auth/* 접근도 허용 (화면 코드에서 성공 시 이동)
      return null;
    },
  );
}

// ───────── 각주 ─────────
// [R1] 이전엔 "loggedIn && isAuthPath → MAIN_AFTER_LOGIN" 강제 규칙이 있었음.
//      이게 로그인/회원가입 화면 진입을 막아, 버튼만 누르면 메인으로 튕겼음.
//      해당 규칙을 제거해 /auth/* 페이지에 정상적으로 머물게 함.

// [R2] 최소한의 보호만 유지: 미로그인이 보호 탭 진입할 때에만 /auth/login 으로 보냄.
//      로그인 완료 시점에 어디로 갈지는 화면(로그인/회원가입)에서 명시적으로 go().
// ─────────────────────── 
