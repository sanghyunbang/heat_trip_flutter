// explore_routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// import 'presentation/screens/explore_screen.dart';
import 'presentation/screens/explore/explore_screen.dart';
import 'presentation/screens/explore_detail_screen.dart';
import 'presentation/state/detail_vm.dart';
import 'data_detail/place_detail_api.dart';
import 'data_detail/place_detail_repository.dart';

List<RouteBase> buildExploreRoutes() {
  // .env에서 값을 “런타임에” 꺼냄
  final serviceKey = dotenv.maybeGet('YOUR_DECODING_SERVICE_KEY') ?? '';
  final mobileOS = dotenv.maybeGet('MOBILE_OS') ?? 'ETC';
  final mobileApp = dotenv.maybeGet('MOBILE_APP') ?? 'HeatTrip';

  // (중요) KorService 버전 통일: 1 또는 2로 통일해서 쓰세요.
  // 여기선 둘 다 KorService1로 맞추는 예시를 사용합니다.
  Uri buildCommonUri() =>
      Uri.https('apis.data.go.kr', '/B551011/KorService2/detailCommon2', {
        'serviceKey': serviceKey, // ← 디코딩 키 사용! (Uri가 알아서 인코딩)
        'MobileOS': mobileOS,
        'MobileApp': mobileApp,
        // 'defaultYN': 'Y',
        // 'addrinfoYN': 'Y',
        // 'mapinfoYN': 'Y',
        // 'overviewYN': 'Y',
        '_type': 'Json',
      });

  Uri buildIntroUri() =>
      Uri.https('apis.data.go.kr', '/B551011/KorService2/detailIntro2', {
        'serviceKey': serviceKey, // ← 디코딩 키 사용! (Uri가 알아서 인코딩)
        'MobileOS': mobileOS,
        'MobileApp': mobileApp,
        '_type': 'Json',
      });

  return [
    GoRoute(
      path: '/explore',
      name: 'explore',
      builder: (context, state) => const ExploreScreen(),
    ),
    GoRoute(
      path: '/explore/:contentId/:contentTypeId',
      name: 'explore_detail',
      pageBuilder: (context, state) {
        final contentId = int.parse(state.pathParameters['contentId']!);
        final contentTypeId = int.parse(state.pathParameters['contentTypeId']!);

        final api = PlaceDetailApi(
          client: http.Client(),
          commonBaseUri: buildCommonUri(), // ← 이제 런타임 조립
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
            ),
          ),
        );
      },
    ),
  ];
}
