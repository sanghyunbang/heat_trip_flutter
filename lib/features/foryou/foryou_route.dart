// lib/features/foryou/foryou_routes.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'presentation/foryou_screen.dart';
import 'presentation/detail_page.dart';
import 'presentation/foryou_vm.dart';

import 'data/remote/recsys_api.dart';
import 'domain/foryou_repository.dart';
import 'data/dto/context_dto.dart';

/// 기본 컨텍스트 (딥링크 등 extra가 없을 때 안전장치)
ContextDto _defaultCtx() => const ContextDto(
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

///  ShellRoute로 감싸서 Provider를 상위에서 주입
/// WHY:
///  - 리스트(/foryou)와 상세(/foryou/detail/:id)가 같은 DI 트리를 공유.
///  - 같은 ForYouVM 인스턴스를 쓰므로 dwell/click/bounce가 한 곳에 모임.
///  - finishDetail()에서 pending dwell을 안전하게 소진하고 /feedback 전송 가능.
final List<RouteBase> foryouRoutes = [
  ShellRoute(
    navigatorKey: foryouNavigatorKey, // (선택) 이 브랜치용 중첩 네비게이터
    builder: (context, state, child) {
      final baseUrl = dotenv.env['API_RECSYS_URL'] ?? 'http://10.0.2.2:8000';

      return MultiProvider(
        providers: [
          // 1) API 주입
          Provider(create: (_) => RecSysApi(baseUrl)),
          // 2) Repo 주입 (API 의존)
          ProxyProvider<RecSysApi, ForYouRepository>(
            update: (_, api, __) => ForYouRepository(api),
          ),
          // 3) VM 주입 (Repo 의존) — 리스트/상세가 같은 인스턴스를 공유
          ChangeNotifierProvider(
            create: (c) => ForYouVM(repo: c.read<ForYouRepository>()),
          ),
        ],
        child: child, // ← 중요! 하위 라우트(page)들이 이 Provider 트리를 공유
      );
    },

    /// 자식 라우트들
    routes: [
      GoRoute(
        path: '/foryou',
        name: 'foryou',
        builder: (context, state) {
          // 부모나 호출자가 전달한 extra(ContextDto)를 받음
          final ctx = (state.extra is ContextDto)
              ? state.extra as ContextDto
              : _defaultCtx(); // 안전장치

          return ForYouScreen(contextDto: ctx, k: 8);
        },
        routes: [
          GoRoute(
            path:
                'detail/:categoryId', // 상대 경로 → 실제는 /foryou/detail/:categoryId
            name: 'foryou_detail',
            builder: (context, state) {
              final cat = state.pathParameters['categoryId']!;
              //  리스트에서 push할 때 넘긴 extra(ContextDto) 받기
              // WHY: finishDetail()에서 동일 컨텍스트로 reward 계산/전송
              final ctx = (state.extra is ContextDto)
                  ? state.extra as ContextDto
                  : _defaultCtx(); // 딥링크 보호

              return CategoryDetailPage(category: cat, contextDto: ctx);
            },
          ),
        ],
      ),
    ],
  ),
];
