/// CategoryCard  [Widget]
/// 역할: 추천 리스트의 한 아이템 카드. 가시성 추적 + 탭 이벤트 노출.
/// 입력: [item] dom.RankItem, [onVisible], [onInvisible], [onTap]
/// 가시성:
///   - 60% 이상 보이면 onVisible() → 노출 시작(Stopwatch start)
///   - 0%가 되면 onInvisible() → 클릭 여부에 따라 즉시/지연 피드백
/// 사용처: ForYouScreen의 SliverList 각 행.
/// 주의: VisibilityDetector 의존(패키지 필요).

// lib/features/foryou/presentation/widgets/category_card.dart
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:heat_trip_flutter/features/foryou/domain/entities/rank_item.dart'
    as dom;

import 'score_pill.dart';

class CategoryCard extends StatelessWidget {
  final dom.RankItem item;
  final VoidCallback onVisible, onInvisible, onTap;

  const CategoryCard({
    super.key,
    required this.item,
    required this.onVisible,
    required this.onInvisible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: VisibilityDetector(
        key: Key('cat-${item.category}'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.6) onVisible();
          if (info.visibleFraction == 0.0) onInvisible();
        },
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [cs.primaryContainer, cs.surfaceVariant],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(.12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: cs.onSecondaryContainer.withOpacity(.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.map, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.category,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '추천 점수 기반 카테고리',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ScorePill(score: item.score),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
