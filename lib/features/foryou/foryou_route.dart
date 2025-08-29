// lib/features/foryou/foryou_route.dart
//
// ──────────────────────────────────────────────────────────────────────────────
// ForYou Feature Route (파일명: foryou_route.dart)
// 역할:
//   - ForYou 기능(추천 리스트/상세)의 라우트 트리를 정의합니다.
//   - Provider 트리를 ShellRoute(builder)에서 주입하여
//     리스트(/foryou)와 상세(/foryou/detail/:id)가 같은 VM/Repo를 공유하게 합니다.
// 의존(필수 패키지):
//   - go_router, provider, flutter_dotenv
// 주의:
//   - presentation 레이어는 도메인 엔티티/인터페이스만 의존(※ DTO/HTTP 모름).
//   - 이 파일은 "파일명은 route(단수)"이지만, export 심볼은 foryouRoutes(List<RouteBase>)입니다.
//     상위 라우터(app_router.dart)에서 StatefulShellBranch(routes: foryouRoutes)로 사용합니다.
// ──────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Screens
import 'presentation/screens/foryou_screen.dart';
import 'presentation/screens/detail_page.dart';

// ViewModel (폴더명을 프로젝트에 맞추세요: state 또는 states)
import 'presentation/states/foryou_vm.dart' // ← 폴더가 state 인 경우
    as vm_file;
// 만약 폴더명이 states 라면 위 한 줄을 주석 처리하고, 아래 줄의 주석을 해제하세요.
// import 'presentation/states/foryou_vm.dart' as vm_file;

// Data & Domain DI
import 'data/remote/recsys_api.dart';
import 'data/foryou_repository_impl.dart';
import 'domain/foryou_repository.dart';
import 'domain/entities/context.dart' as dom;

/// 기본 컨텍스트 (딥링크 등에서 extra 누락 시 안전장치)
dom.Context _defaultCtx() => const dom.Context(
  P: 1,
  A: -1,
  D: 2,
  sociality: 1,
  noise: -1,
  crowdedness: -1,
  location: 'in',
);

/// (선택) 이 브랜치 전용 네비게이터 키
final GlobalKey<NavigatorState> foryouNavigatorKey =
    GlobalKey<NavigatorState>();

/// ForYou 라우트 트리
///
/// 구조:
///   ShellRoute (Provider 주입)
///     └── GoRoute('/foryou')                : 리스트 화면
///           └── GoRoute('detail/:categoryId'): 상세 화면
///
/// 상위(app_router.dart)에서:
///   StatefulShellBranch(routes: foryouRoutes)
final List<RouteBase> foryouRoutes = [
  ShellRoute(
    navigatorKey: foryouNavigatorKey,
    builder: (context, state, child) {
      // .env가 없어도 앱이 뜨도록 기본값 지정
      final baseUrl = dotenv.env['API_RECSYS_URL'] ?? 'http://10.0.2.2:8000';

      return MultiProvider(
        providers: [
          // 1) API 주입
          Provider(create: (_) => RecSysApi(baseUrl)),
          // 2) Repo 구현체 주입 (API 의존)
          ProxyProvider<RecSysApi, ForYouRepository>(
            update: (_, api, __) => ForYouRepositoryImpl(api),
          ),
          // 3) VM 주입 (Repo 의존) — 리스트/상세가 같은 인스턴스를 공유
          ChangeNotifierProvider(
            create: (c) => vm_file.ForYouVM(repo: c.read<ForYouRepository>()),
          ),
        ],
        child: child,
      );
    },

    routes: [
      GoRoute(
        path: '/foryou',
        name: 'foryou',
        builder: (context, state) {
          // 부모나 호출자가 전달한 extra(dom.Context)를 받음
          final ctx = (state.extra is dom.Context)
              ? state.extra as dom.Context
              : _defaultCtx(); // 안전장치

          return ForYouScreen(contextModel: ctx, k: 8);
        },
        routes: [
          GoRoute(
            path: 'detail/:categoryId', // 실제 경로: /foryou/detail/:categoryId
            name: 'foryou_detail',
            builder: (context, state) {
              final cat = state.pathParameters['categoryId']!;
              // 리스트에서 push할 때 넘긴 extra(dom.Context) 받기
              // WHY: finishDetail()에서 동일 컨텍스트로 reward 계산/전송
              final ctx = (state.extra is dom.Context)
                  ? state.extra as dom.Context
                  : _defaultCtx(); // 딥링크 보호

              return CategoryDetailPage(category: cat, contextModel: ctx);
            },
          ),
        ],
      ),
    ],
  ),
];
