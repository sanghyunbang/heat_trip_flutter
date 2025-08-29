// lib/main.dart
import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// go_router 설정만 받아옴
import 'package:heat_trip_flutter/app/app_router.dart';
// 기존 테마
import 'package:heat_trip_flutter/core/theme/theme.dart';

Future<void> main() async {
  // 비동기 초기화 전에 바인딩
  WidgetsFlutterBinding.ensureInitialized();

  // .env 로드 (없어도 앱이 죽지 않게)
  try {
    await dotenv.load(); // 또는: await dotenv.load(fileName: '.env');
  } catch (e, st) {
    debugPrint('[dotenv] load skipped or failed: $e');
    if (kDebugMode) {
      debugPrintStack(stackTrace: st);
    }
  }

  // Flutter 위젯 트리에서 발생한 모든 에러를 콘솔로
  FlutterError.onError = (FlutterErrorDetails details) {
    // 기본 덤프
    FlutterError.dumpErrorToConsole(details);
    // 원한다면 여기서 Sentry/Crashlytics로 전송
  };

  // 위젯 빌드 중 에러가 나면 빨간 에러 위젯 대신 친절한 위젯으로 대체
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

  // 프레임워크 밖(PlatformDispatcher)에서 던져진 예외도 잡아 앱 종료 방지
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('UNCAUGHT (PlatformDispatcher): $error');
    if (kDebugMode) {
      debugPrintStack(stackTrace: stack);
    }
    return true; // true 반환 시 프로세스 종료를 막음
  };

  // runZonedGuarded로 비동기 예외까지 수집
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
    // (선택) 디버깅 도움 옵션 — 필요할 때 주석 해제
    // debugPrintRebuildDirtyWidgets = true; // 어떤 위젯이 다시 빌드되는지 로그
    // debugPrintScheduleBuildForStacks = true; // 빌드 스케줄 스택 로깅

    return MaterialApp.router(
      title: '여행의 온도',
      debugShowCheckedModeBanner: false,
      theme: theme(),
      // go_router 사용
      routerConfig: appRouter,
      // (선택) 여기서도 최상위 위젯을 감싸 전역 에러 UI를 둘 수 있음
      builder: (context, child) {
        // child가 null일 일은 거의 없지만, 방어적으로 처리
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
