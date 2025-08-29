/// ThumbBox  [Widget]
/// 역할: 갤러리의 썸네일 플레이스홀더.
/// 입력: [index] 리스트 인덱스(애니메이션 지연에 활용).
/// 사용처: DetailPage '갤러리' 섹션의 가로 스크롤 목록.
/// 비고: 실제 이미지 공급 전까지는 Placeholder로 사용.

// lib/features/foryou/presentation/widgets/thumb_box.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ThumbBox extends StatelessWidget {
  final int index;
  const ThumbBox({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        height: 120,
        color: cs.surfaceVariant,
        child: Center(child: Text('IMG ${index + 1}')),
      ),
    ).animate().fadeIn(duration: 250.ms, delay: (index * 40).ms);
  }
}
