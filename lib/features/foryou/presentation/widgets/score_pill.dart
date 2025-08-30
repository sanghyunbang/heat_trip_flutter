/// ScorePill  [Widget]
/// 역할: 추천 점수를 고정폭 숫자(tabular figures)로 라벨 표시.
/// 입력: [score] double
/// 사용처: CategoryCard 우측 점수 배지.
/// 비고: 시각적 보조. 로직 없음.

// lib/features/foryou/presentation/widgets/score_pill.dart
// lib/features/foryou/presentation/widgets/score_pill.dart
import 'package:flutter/material.dart';
import 'dart:ui' show FontFeature;

class _Pal {
  static const bg200 = Color(0xFFEBE2CD);
  static const bg300 = Color(0xFFC2BAA6);
  static const text100 = Color(0xFF353535);
}

class ScorePill extends StatelessWidget {
  final double score;
  const ScorePill({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    // 아주 작은 pill + 탭 고정폭 숫자
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _Pal.bg200.withOpacity(.42),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _Pal.bg300.withOpacity(.55), width: 0.6),
      ),
      child: Text(
        score.toStringAsFixed(3),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white, // 그라데이션 위 대비를 위해 흰색
          // 숫자 정렬 안정화
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
