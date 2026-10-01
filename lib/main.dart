// lib/main.dart
//
// 목적:
// - 전역 Provider DI 구성 (AuthState, ApiClient, AuthRepositoryImpl 주입)
// - .env 및 --dart-define를 통한 baseUrl 구성
// - Flutter/플랫폼/비동기 예외 핸들링 기본 설정
// - AuthState를 router의 refreshListenable로 연결하여 로그인 상태 변화 시 라우팅 재평가
//
// 핵심 포인트:
// 1) ApiClient.tokenProvider ← TokenStorage.getToken → 매 요청 최신 토큰 반영
// 2) AuthState()..refresh() → 앱 시작 시 저장된 토큰 기반 초기 동기화
// 3) ProxyProvider<ApiClient, AuthRepositoryImpl> → 화면에서 new 하지 말고 DI
// 4) buildAppRouter(refreshListenable: context.read<AuthState>()) 로 가드 활성화
// 5) [Journey] ChangeNotifierProxyProvider로 JourneyState를 주입하고, 앱 시작 시 bootstrap() 실행
// 6) [Journey] 상태 계층을 통해 작성 즉시(낙관적) 리스트에 반영되도록 함
// 7) [★ Media] MediaApiClient/MediaRepository를 전역 DI에 추가 → 사진 업로드 위젯 재사용

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:heat_trip_flutter/app/app_router.dart';
import 'package:heat_trip_flutter/core/theme/theme.dart';
import 'package:heat_trip_flutter/shared/network/api_client.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:heat_trip_flutter/features/auth/state/auth_state.dart';
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';

// [Journey]
import 'package:heat_trip_flutter/features/journey/state/journey_state.dart';
import 'package:heat_trip_flutter/features/journey/data/journey_api.dart';

// [★ Media] 배럴 import: MediaApiClient / MediaRepository
import 'package:heat_trip_flutter/shared/media/media.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 로드 (없어도 앱이 실행되도록 너그럽게 처리)
  try {
    await dotenv.load(); // 루트 .env
  } catch (_) {
    // 무시: --dart-define만 쓰는 환경일 수 있음
  }

  // 프레임워크 내부 에러
  FlutterError.onError = FlutterError.dumpErrorToConsole;

  // 프레임워크 밖(플랫폼) 예외
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('UNCAUGHT (PlatformDispatcher): $error');
    if (kDebugMode) debugPrintStack(stackTrace: stack);
    return true; // true면 프로세스 종료 방지
  };

  // 비동기 예외 마지막 방어선
  runZonedGuarded(
    () => runApp(const HeatTrip()),
    (error, stack) {
      debugPrint('UNCAUGHT (runZonedGuarded): $error');
      if (kDebugMode) debugPrintStack(stackTrace: stack);
    },
  );
}

class HeatTrip extends StatelessWidget {
  const HeatTrip({super.key});

  @override
  Widget build(BuildContext context) {
    // 우선순위:
    // 1) --dart-define
    // 2) .env
    // 3) 기본값(에뮬레이터: 10.0.2.2:8080)
    const fromDefine = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8080',
    );
    final baseUrl = dotenv.env['API_BASE_URL']?.isNotEmpty == true
        ? dotenv.env['API_BASE_URL']!
        : fromDefine;

    return MultiProvider(
      providers: [
        // 로그인 상태
        ChangeNotifierProvider(create: (_) => AuthState()..refresh()),

        // 공용 HTTP 클라이언트
        Provider(
          create: (_) => ApiClient(
            baseUrl: baseUrl,
            tokenProvider: TokenStorage.getToken, // 요청 시점마다 최신 토큰
          ),
        ),

        // ApiClient → AuthRepositoryImpl 주입 (DI 체인 완성)
        ProxyProvider<ApiClient, AuthRepositoryImpl>(
          update: (_, api, __) => AuthRepositoryImpl(api),
        ),

        // ─────────────────────────────────────────────────────────
        // [★ Media] 업로드(S3/CDN) 클라이언트 + 레포 주입
        Provider(
          create: (_) => MediaApiClient(
            baseUrl: baseUrl,
            tokenProvider: TokenStorage.getToken, // 매 요청 최신 토큰
          ),
        ),
        ProxyProvider<MediaApiClient, MediaRepository>(
          update: (_, mediaApi, __) => MediaRepository(mediaApi),
        ),
        // ─────────────────────────────────────────────────────────

        // [Journey] JourneyState 전역 주입 (+ bootstrap)
        ChangeNotifierProxyProvider<ApiClient, JourneyState>(
          create: (ctx) {
            final apiClient = ctx.read<ApiClient>();
            final state = JourneyState(
              api: RealJourneyApi(apiClient),
              apiClient: apiClient,
            );
            state.bootstrap();
            return state;
          },
          update: (ctx, apiClient, prev) {
            return prev ??
                (JourneyState(
                  api: RealJourneyApi(apiClient),
                  apiClient: apiClient,
                )..bootstrap());
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          // 로그인 상태 변화 시 라우터 가드 재평가
          final router = buildAppRouter(
            refreshListenable: context.read<AuthState>(),
          );

          return MaterialApp.router(
            title: '여행의 온도',
            debugShowCheckedModeBanner: false,
            theme: theme(),
            routerConfig: router,
          );
        },
      ),
    );
  }
}

/* ───────────── 각주 ─────────────
[DI 흐름]
  SignUpScreen
    └─(read) AuthRepositoryImpl
         └─(has) ApiClient
              └─(tokenProvider) TokenStorage.getToken
  [Journey]
    JourneyScreen / NewDiaryScreen / JourneyDetailScreen
      └─(watch/read) JourneyState
           └─(has) JourneyApi(RealJourneyApi(ApiClient)), JourneyRepositoryImpl(ApiClient)
  [★ Media]
    NewDiaryScreen(MediaGridField) / AvatarPicker
      └─(read) MediaRepository
           └─(has) MediaApiClient(baseUrl, tokenProvider) → /media 컨트롤러와 통신

[왜 화면에서 new 하지 않나?]
  - 테스트/유지보수/상태 공유를 위해 의존성은 상위에서 조립(DI)하고, 화면은 사용만 합니다.
  - [Journey] 작성/수정/삭제는 JourneyState 메서드를 통해 낙관적 갱신 → 즉시 UI 반영 → 실패 시 롤백.
──────────────────────── */
