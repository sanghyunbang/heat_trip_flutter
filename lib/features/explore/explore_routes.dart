// lib/features/explore/explore_routes.dart
//
// Home → Explore(list) → Detail 라우팅
// - /explore/list로 이동할 때 쿼리(Map<String,String>)를 Provider로 주입
// - ExploreScreen이 쿼리 유무로 검색/커서 모드 자동 전환
//
// ✅ 변경 사항
// - 상세 라우트에서 go_router의 `state.extra`로 전달된 seedImage(String?)를 수신
// - ExploreDetailScreen(seedImage: ...)에 그대로 전달하여,
//   외부 API 실패 시에도 목록의 썸네일을 상단 갤러리에 fallback으로 표시

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Screens
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/explore/explore_screen.dart';
import 'presentation/screens/explore_detail_screen.dart';

// Detail DI (KTO 상세)
import 'data_detail/place_detail_api.dart';
import 'data_detail/place_detail_repository.dart';
import 'presentation/state/detail_vm.dart';

List<RouteBase> buildExploreRoutes() {
  // .env 로드 (상세 화면에서만 사용)
  final serviceKey = dotenv.maybeGet('YOUR_DECODING_SERVICE_KEY') ?? '';
  final mobileOS = dotenv.maybeGet('MOBILE_OS') ?? 'ETC';
  final mobileApp = dotenv.maybeGet('MOBILE_APP') ?? 'HeatTrip';

  // ⚠️ KTO는 `_type=json` (소문자) 권장
  Uri buildCommonUri() =>
      Uri.https('apis.data.go.kr', '/B551011/KorService2/detailCommon2', {
        'serviceKey': serviceKey,
        'MobileOS': mobileOS,
        'MobileApp': mobileApp,
        '_type': 'json',
      });

  Uri buildIntroUri() =>
      Uri.https('apis.data.go.kr', '/B551011/KorService2/detailIntro2', {
        'serviceKey': serviceKey,
        'MobileOS': mobileOS,
        'MobileApp': mobileApp,
        '_type': 'json',
      });

  return <RouteBase>[
    // 🔹 Explore 홈(정적 카드)
    GoRoute(
      path: '/explore',
      name: 'explore_home',
      pageBuilder: (context, state) => const MaterialPage(child: HomeScreen()),
    ),

    // 🔹 목록 화면
    //    예: /explore/list?themeId=healing&contentTypeId=12&q=카페&cat3=A02010800
    GoRoute(
      path: '/explore/list',
      name: 'explore_list',
      pageBuilder: (context, state) {
        final query = state.uri.queryParameters; // Map<String,String>
        return MaterialPage(
          child: Provider<Map<String, String>>.value(
            value: query, // Home에서 실어보낸 query를 그대로 주입
            child: const ExploreScreen(),
          ),
        );
      },
    ),

    // 🔹 상세 화면
    GoRoute(
      path: '/explore/:contentId/:contentTypeId',
      name: 'explore_detail',
      pageBuilder: (context, state) {
        final contentId = int.parse(state.pathParameters['contentId']!);
        final contentTypeId = int.parse(state.pathParameters['contentTypeId']!);

        // ✅ 카드에서 extra로 보낸 seedImage(String?) 수신
        final String? seedImage = state.extra is String
            ? state.extra as String
            : null;

        // DI: API/Repo/VM
        final api = PlaceDetailApi(
          client: http.Client(),
          commonBaseUri: buildCommonUri(),
          introBaseUri: buildIntroUri(),
        );
        final repo = PlaceDetailRepository(api);

        return MaterialPage(
          child: MultiProvider(
            providers: [
              Provider<PlaceDetailRepository>.value(value: repo),
              ChangeNotifierProvider(
                create: (ctx) => DetailVM(ctx.read<PlaceDetailRepository>()),
              ),
            ],
            child: ExploreDetailScreen(
              contentId: contentId,
              contentTypeId: contentTypeId,
              seedImage: seedImage, // ✅ 상세에 전달
            ),
          ),
        );
      },
    ),
  ];
}
