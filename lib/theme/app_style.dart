// lib/theme/app_style.dart
import 'package:flutter/material.dart';

class AppPal {
  static const primary100 = Color(0xFFEB9C64); // orange
  static const primary200 = Color(0xFFFF8789); // pink
  static const primary300 = Color(0xFF554E4F);
  static const accent100 = Color(0xFF8FBF9F); // green
  static const accent200 = Color(0xFF346145); // deep green
  static const text100 = Color(0xFF353535);
  static const text200 = Color(0xFF000000);
  static const bg100 = Color(0xFFF5ECD7);
  static const bg200 = Color(0xFFEBE2CD);
  static const bg300 = Color(0xFFC2BAA6);
}

class AppGradients {
  /// 상단 상태 요약: 스크린샷 느낌 (오렌지→핑크, 좌상→우하)
  static const status = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppPal.primary100, AppPal.primary200],
  );

  /// 카드: 상단과 확실히 다르게 (그린→오렌지, 우상→좌하)
  static const card = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppPal.accent100, AppPal.primary100],
  );

  /// (옵션) 더 강한 대비가 필요할 때 쓰는 3색 카드 그라데이션
  static const cardAlt = LinearGradient(
    begin: Alignment(0.9, -0.8),
    end: Alignment(-0.9, 0.8),
    colors: [AppPal.accent100, AppPal.primary100, AppPal.accent200],
    stops: [0.0, 0.6, 1.0],
  );
}
