// lib/main.dart
//
// 목적
// - 전역 DI(MultiProvider)로 MediaApiClient/MediaRepository를 주입.
// - MediaApiClient에 tokenProvider를 주입해 /media 호출 시 401/403 방지. [①]
// - 에러 핸들링(Widget build, 플랫폼, 비동기) 기본 설정.
//
// 필수 포인트
// - --dart-define=API_BASE_URL=... 또는 .env를 통해 baseUrl 지정 가능. [②]
// - Provider를 사용하는 모든 화면(AvatarPicker/MediaRepository 등)이 의존성을 해결하게 됨. [③]

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// go_router 설정
import 'package:heat_trip_flutter/app/app_router.dart';
// 기본 테마
import 'package:heat_trip_flutter/core/theme/theme.dart';

// ★ shared/media 배럴 (models, picker, api client, repository, widgets 포함)
import 'package:heat_trip_flutter/shared/media/media.dart';
// ★ 토큰 저장 서비스 (Bearer 주입에 사용)
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';

Future<void> main() async {
  // 비동기 초기화 전에 바인딩
  WidgetsFlutterBinding.ensureInitialized();

  // .env 로드 (없어도 앱이 죽지 않게 try-catch)
  try {
    await dotenv.load(); // 또는 await dotenv.load(fileName: '.env');
  } catch (e, st) {
    debugPrint('[dotenv] load skipped or failed: $e');
    if (kDebugMode) {
      debugPrintStack(stackTrace: st);
    }
  }

  // Flutter 위젯 트리에서 발생한 모든 에러를 콘솔로
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    // 필요 시 Sentry/Crashlytics 전송 지점
  };

  // 위젯 빌드 중 에러 UI 대체
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kReleaseMode) {
      return const SizedBox.shrink(); // 릴리스에선 빈 위젯
    }
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(.3)),
        ),
        child: SingleChildScrollView(
          child: Text(
            'Widget build error:\n\n${details.exceptionAsString()}',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  };

  // 프레임워크 밖에서 던져진 예외도 잡아 앱 종료 방지
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('UNCAUGHT (PlatformDispatcher): $error');
    if (kDebugMode) {
      debugPrintStack(stackTrace: stack);
    }
    return true; // true 반환 시 프로세스 종료를 막음
  };

  // 비동기 예외 수집
  runZonedGuarded(() => runApp(const HeatTrip()), (error, stack) {
    debugPrint('UNCAUGHT (runZonedGuarded): $error');
    if (kDebugMode) {
      debugPrintStack(stackTrace: stack);
    }
  });
}

class HeatTrip extends StatelessWidget {
  const HeatTrip({super.key});

  @override
  Widget build(BuildContext context) {
    // --dart-define=API_BASE_URL 값이 있으면 사용, 없으면 10.0.2.2(안드로이드 에뮬)의 8080
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8080',
    );

    return MultiProvider(
      providers: [
        // [A] MediaApiClient: Authorization 토큰을 주입하기 위해 tokenProvider 설정. [①]
        Provider(
          create: (_) => MediaApiClient(
            baseUrl: baseUrl,
            tokenProvider: () async => await TokenStorage.getToken(),
          ),
        ),
        // [B] MediaRepository: API 클라이언트를 의존성으로 받음. [③]
        ProxyProvider<MediaApiClient, MediaRepository>(
          update: (_, api, __) => MediaRepository(api),
        ),
      ],
      child: MaterialApp.router(
        title: '여행의 온도',
        debugShowCheckedModeBanner: false,
        theme: theme(),
        routerConfig: appRouter,
        builder: (context, child) => child ?? const SizedBox.shrink(),
      ),
    );
  }
}

/* ─────────────────────────── 각주 ───────────────────────────
[①] /media 엔드포인트는 @SecurityRequirement에 의해 인증이 필요합니다.
     tokenProvider를 주입하지 않으면 업로드 시 401/403이 떨어지고,
     로컬 미리보기만 보이는 "착시"가 발생합니다.

[②] baseUrl은 dev/prod에서 달라질 수 있습니다. 빌드 시 --dart-define 또는 .env로 관리하세요.

[③] AvatarPicker → MediaRepository → MediaApiClient → 백엔드(/media)
     라는 계층으로 연결되어 있으며, Provider가 없으면 의존성 주입에 실패합니다.
────────────────────────────────────────────────────────── */
