/// reviews_card.dart
/// - 총 리뷰 수를 헤더에 표기
/// - 상위 3개만 미리보기 (추후 '모든 리뷰 보기' 눌렀을 때 라우팅/시트 확장 가능)
import 'package:flutter/material.dart';
import '../../domain/entity_detail/place_detail.dart';

class ReviewsCard extends StatelessWidget {
  final List<Review> reviews;
  const ReviewsCard({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();

    final top = reviews.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 총 개수 + 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '리뷰 (${reviews.length})',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                OutlinedButton(
                  onPressed: () {
                    // TODO: 리뷰 전체 보기 라우팅/바텀시트 등 연결
                  },
                  child: const Text('모든 리뷰 보기'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 리뷰 3개 미리보기
            ...top.map(
              (r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 작성자/별점/날짜줄
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              r.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < r.rating ? Icons.star : Icons.star_border,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          r.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // 본문
                    Text(r.comment),

                    const SizedBox(height: 4),

                    // 도움됨 카운트
                    Text(
                      '👍 도움됨 ${r.helpful}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
