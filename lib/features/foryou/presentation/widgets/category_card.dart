/// CategoryCard  [Widget]
/// 역할: 추천 리스트의 한 아이템 카드. 가시성 추적 + 탭 이벤트 노출.
/// 입력: [item] dom.RankItem, [onVisible], [onInvisible], [onTap]
/// 가시성:
///   - 60% 이상 보이면 onVisible() → 노출 시작(Stopwatch start)
///   - 0%가 되면 onInvisible() → 클릭 여부에 따라 즉시/지연 피드백
/// 사용처: ForYouScreen의 SliverList 각 행.
/// 주의: VisibilityDetector 의존(패키지 필요).

// lib/features/foryou/presentation/widgets/category_card.dart
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:heat_trip_flutter/features/foryou/domain/entities/rank_item.dart'
    as dom;

class _Pal {
  static const text100 = Color(0xFF353535);
  static const bg200 = Color(0xFFEBE2CD);
  static const bg300 = Color(0xFFC2BAA6);
  static const primary100 = Color(0xFFEB9C64); // icon tile 기본
  static const primary200 = Color(0xFFFF8789); // 필요시 다른 타일색
}

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
    final radius = BorderRadius.circular(12);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: VisibilityDetector(
        key: Key('cat-${item.category}'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.6) onVisible();
          if (info.visibleFraction == 0.0) onInvisible();
        },
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: _Pal.bg300.withOpacity(.25),
          highlightColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              // 행(로우)은 플랫하게: 상위 패널이 배경/그림자를 가짐
              color: Colors.transparent,
              borderRadius: radius,
            ),
            child: Row(
              children: [
                // 왼쪽 작은 아이콘 스퀘어
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _Pal.primary100.withOpacity(.20),
                    border: Border.all(
                      color: _Pal.primary100.withOpacity(.55),
                      width: .8,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.map, size: 22, color: Colors.black87),
                ),
                const SizedBox(width: 12),

                // 가운데 텍스트들
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _Pal.text100,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '추천 점수 기반 카테고리',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0x99000000), // 약한 회색
                          fontSize: 12,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),

                // 오른쪽 점수 (칩 대신 텍스트, 고정폭 숫자)
                Text(
                  _formatScore(item.score),
                  style: const TextStyle(
                    color: _Pal.text100,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatScore(double s) {
    final sign = s >= 0 ? '+' : '';
    // 필요에 따라 소수점 자릿수 변경
    return '$sign${s.toStringAsFixed(3)}';
  }
}
