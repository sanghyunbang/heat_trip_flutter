/// ScorePill  [Widget]
/// 역할: 추천 점수를 고정폭 숫자(tabular figures)로 라벨 표시.
/// 입력: [score] double
/// 사용처: CategoryCard 우측 점수 배지.
/// 비고: 시각적 보조. 로직 없음.

// lib/features/foryou/presentation/widgets/score_pill.dart
import 'package:flutter/material.dart';

class ScorePill extends StatelessWidget {
  final double score;
  const ScorePill({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.secondaryContainer;
    final fg = Theme.of(context).colorScheme.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        score.toStringAsFixed(3),
        style: TextStyle(
          color: fg,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
