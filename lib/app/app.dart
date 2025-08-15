import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_router.dart';
// import 'package:google_fonts/google_fonts.dart'; // (선택) Inter 폰트 사용 시

/// 전역 테마/라우터를 묶는 루트 위젯
class HeatTripApp extends StatelessWidget {
  const HeatTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    // WHY: 라우팅 정의는 별도 파일(app_router.dart)로 분리하여 충돌 최소화
    final GoRouter router = appRouter;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'HeatTrip',
      theme: ThemeData(
        // WHAT: HTML 시안(따뜻한 오프화이트/브라운 톤)을 반영한 시드 컬러
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B5A3D)),
        useMaterial3: true,
        // textTheme: GoogleFonts.interTextTheme(), // (선택)
      ),
    );
  }
}
