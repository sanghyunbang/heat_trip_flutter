// lib/features/foryou/foryou_route.dart
//
// ──────────────────────────────────────────────────────────────────────────────
// ForYou Feature Route
// - ShellRoute에서 Provider 트리를 주입하여 리스트(/foryou)와 상세(/foryou/detail/:id)
//   가 같은 VM/Repo 인스턴스를 공유합니다.
// - .env 가 없더라도 기본값으로 동작.
//
// 필요 패키지: go_router, provider, flutter_dotenv
// ──────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Screens
import 'presentation/screens/foryou_screen.dart';
import 'presentation/screens/detail_page.dart';

// ViewModel (alias 사용: 프로젝트에 따라 폴더명이 states/state 다를 수 있음)
import 'presentation/states/foryou_vm.dart' as vm_file;

// Data & Domain DI
import 'data/remote/recsys_api.dart';
import 'data/foryou_repository_impl.dart';
import 'domain/foryou_repository.dart';
import 'domain/entities/context.dart' as dom;

/// 딥링크/누락 대비 기본 컨텍스트(energy/social만 사용)
dom.Context _defaultCtx() => const dom.Context(
  energy: 5, // 0~10
  social: 5, // 0~10 (낮음=혼자, 높음=함께)
  location: 'mix', // 'in' | 'out' | 'mix'
);

/// 이 브랜치 전용 네비게이터 키(선택)
final GlobalKey<NavigatorState> foryouNavigatorKey =
    GlobalKey<NavigatorState>();

/// 상위 라우터(app_router.dart)에서 StatefulShellBranch(routes: foryouRoutes)로 사용
final List<RouteBase> foryouRoutes = [
  ShellRoute(
    navigatorKey: foryouNavigatorKey,
    builder: (context, state, child) {
      // .env 미설정 시에도 동작하도록 기본값 설정
      final baseUrl = dotenv.env['API_RECSYS_URL'] ?? 'http://10.0.2.2:8000';

      return MultiProvider(
        providers: [
          // 1) API 클라이언트 주입(현재는 Mock)
          Provider(create: (_) => RecSysApi(baseUrl)),
          // 2) 레포지토리 구현 주입(API 의존)
          ProxyProvider<RecSysApi, ForYouRepository>(
            update: (_, api, __) => ForYouRepositoryImpl(api),
          ),
          // 3) VM(ChangeNotifier) 주입(Repo 의존)
          ChangeNotifierProvider(
            create: (c) => vm_file.ForYouVM(repo: c.read<ForYouRepository>()),
          ),
        ],
        child: child,
      );
    },

    routes: [
      // /foryou (메인 리스트)
      GoRoute(
        path: '/foryou',
        name: 'foryou',
        builder: (context, state) {
          final ctx = (state.extra is dom.Context)
              ? state.extra as dom.Context
              : _defaultCtx();
          return ForYouScreen(contextModel: ctx, k: 8);
        },
        routes: [
          // /foryou/detail/:categoryId (카테고리 상세)
          GoRoute(
            path: 'detail/:categoryId',
            name: 'foryou_detail',
            builder: (context, state) {
              final cat = state.pathParameters['categoryId']!;
              final ctx = (state.extra is dom.Context)
                  ? state.extra as dom.Context
                  : _defaultCtx();
              return CategoryDetailPage(category: cat, contextModel: ctx);
            },
          ),
        ],
      ),
    ],
  ),
];
