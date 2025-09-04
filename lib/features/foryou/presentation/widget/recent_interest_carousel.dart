import 'package:flutter/material.dart';
import '../../domain/entities/local_destination.dart';

/// 최근 관심 여행지 가로 캐러셀
/// - 고정 높이를 넉넉히 잡아 overflow 방지
/// - 텍스트 줄간격(height)을 낮춰 여유 확보
class RecentInterestCarousel extends StatelessWidget {
  final List<LocalDestination> items;
  final VoidCallback onSeeAll;
  const RecentInterestCarousel({
    super.key,
    required this.items,
    required this.onSeeAll,
  });

  // 레이아웃 상수(작게 조정하려면 아래 숫자만 바꾸면 됩니다)
  static const double _tileWidth = 120;
  static const double _imageHeight = 74; // 64 → 74 로 살짝 키워도 여유 있음
  static const double _tileHeight = 118; // 96 → 118 로 증가(overflow 방지)

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                const Icon(Icons.favorite_border, color: Colors.redAccent),
                const SizedBox(width: 6),
                const Text(
                  '최근 관심 여행지',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton(onPressed: onSeeAll, child: const Text('전체보기')),
              ],
            ),
            const SizedBox(height: 8),

            // 가로 캐러셀(고정 높이)
            SizedBox(
              height: _tileHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _RecentTile(d: items[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final LocalDestination d;
  const _RecentTile({required this.d});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: RecentInterestCarousel._tileWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지(에러 시 심플한 플레이스홀더)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              d.imageUrl,
              height: RecentInterestCarousel._imageHeight,
              width: RecentInterestCarousel._tileWidth,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: RecentInterestCarousel._imageHeight,
                width: RecentInterestCarousel._tileWidth,
                color: Colors.black12,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // 제목(1줄, 줄간격 낮춤)
          Text(
            d.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.1, // 줄간격 축소
            ),
          ),

          // 위치(1줄, 줄간격 낮춤)
          Text(
            d.location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
              height: 1.1, // 줄간격 축소
            ),
          ),
        ],
      ),
    );
  }
}
