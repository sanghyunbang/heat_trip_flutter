/// TitleRow  [Widget]
/// 역할: 상세 상단의 제목/부제 + '추천' 핀 배지 행.
/// 입력: [code] 카테고리 코드/이름, [scoreText] 보조 텍스트
/// 사용처: DetailPage 요약 상단.
/// 비고: 시각적 구성 요소. 데이터 로직 없음.

// lib/features/foryou/presentation/widgets/title_row.dart
import 'package:flutter/material.dart';

class TitleRow extends StatelessWidget {
  final String code;
  final String scoreText;
  const TitleRow({super.key, required this.code, required this.scoreText});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                code,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                scoreText,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Icon(Icons.trending_up, color: cs.onSecondaryContainer, size: 16),
              const SizedBox(width: 6),
              Text('추천', style: TextStyle(color: cs.onSecondaryContainer)),
            ],
          ),
        ),
      ],
    );
  }
}
