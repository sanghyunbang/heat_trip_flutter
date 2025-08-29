/// SkeletonCard  [Widget]
/// 역할: 로딩 상태에서 리스트 자리 채우기(스켈레톤 UI).
/// 입력: 없음
/// 사용처: ForYouScreen에서 VM.loading == true일 때.
/// 비고: 애니메이션은 상위에서 감싸서 적용(예: .fadeIn()).

// lib/features/foryou/presentation/widgets/skeleton_card.dart
import 'package:flutter/material.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: cs.surfaceVariant.withOpacity(.6),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
