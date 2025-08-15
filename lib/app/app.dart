// lib/app/app.dart (또는 main.dart에서 직접 써도 됨)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/core/theme/theme.dart'; // <- 기존 theme.dart 그대로
import 'app_router.dart';

class HeatTripApp extends StatelessWidget {
  const HeatTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter, // 아래에서 정의
      theme: theme(), // <- 기존 테마 적용
    );
  }
}
