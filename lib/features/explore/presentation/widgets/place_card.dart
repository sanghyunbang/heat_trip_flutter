// =============================
// place_card.dart — vertical card like the 2nd screenshot
// =============================
// 목적
// - 두 번째 스샷처럼 "상단 큰 이미지 + 하단 정보" 카드 레이아웃
// - 현재 PlaceItem의 필드(title/addr1/firstimage/contentid)만 사용 → 컴파일 에러 없음
// - 배지/가격/평점/거리/시간/태그는 "옵션 파라미터"로 주면 표시, 없으면 감춤(우아한 degrade)
// - 가로형(좌썸네일)도 유지하지만, 기본은 vertical로 변경

import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';
import 'package:heat_trip_flutter/features/explore/presentation/screens/explore_detail_screen.dart';

enum PlaceCardLayout { horizontal, vertical }

class PlaceCard extends StatelessWidget {
  final PlaceItem data;
  final PlaceCardLayout layout;

  // ▼ 두 번째 스샷을 위해 필요한(하지만 현재 DTO에 없을 수 있는) 값들 — 선택 입력
  final String? categoryLabel; // 예: '카페'
  final String? priceLabel; // 예: '$$' 또는 '₩₩'
  final double? rating; // 예: 4.8
  final String? distance; // 예: '0.5km'
  final String? duration; // 예: '1-2시간'
  final List<String>? tags; // 예: ['전통','차분함','문화']
  final bool showHeart; // 우하단 하트 표시 여부

  // 가로형 카드에서만 사용되는 왼쪽 썸네일 폭
  final double thumbnailWidth;

  const PlaceCard({
    super.key,
    required this.data,
    this.layout = PlaceCardLayout.vertical, // 기본: 세로형(두 번째 스샷 스타일)
    this.categoryLabel,
    this.priceLabel,
    this.rating,
    this.distance,
    this.duration,
    this.tags,
    this.showHeart = true,
    this.thumbnailWidth = 160,
  });

  // 주소를 안전하게 짧게 표기
  String _shortAddr(String? addr) {
    if (addr == null) return '';
    final t = addr.trim();
    if (t.isEmpty) return '';
    final parts = t.split(RegExp(r'\s+'));
    return parts.length >= 2 ? '${parts[0]} ${parts[1]}' : t;
  }

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case PlaceCardLayout.horizontal:
        return _buildHorizontal(context);
      case PlaceCardLayout.vertical:
      default:
        return _buildVertical(context);
    }
  }

  // ---------------------------------------------------------------------------
  // 세로형 카드(두 번째 스샷)
  // - 상단: 큰 이미지(16:9) + 배지/가격/하트 오버레이
  // - 하단: 제목, 메타(주소/거리/시간), 평점, 태그(옵션)
  // ---------------------------------------------------------------------------
  Widget _buildVertical(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return Card(
      elevation: 0, // 그림자 제거
      shadowColor: Colors.transparent,
      color: Colors.white, // 카드 바탕은 흰색
      surfaceTintColor: Colors.transparent, // M3 틴트 제거(회색끼 방지)
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant, // 외곽선 색
          width: 1, // 외곽선 두께
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ExploreDetailScreen(data: data)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) 이미지 영역: 16:9 비율 유지 + 오버레이들
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: 'place:${data.contentid}',
                      child: Image.network(
                        data.firstimage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.network(
                          'https://cdn.pixabay.com/photo/2019/07/08/04/23/traveling-4323759_1280.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // 좌상단: 카테고리 배지 (옵션)
                  if ((categoryLabel ?? '').isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _BadgeChip(
                        icon: Icons.local_cafe_outlined,
                        label: categoryLabel!,
                      ),
                    ),

                  // 우상단: 가격 배지 (옵션)
                  if ((priceLabel ?? '').isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _BadgePill(text: priceLabel!),
                    ),

                  // 우하단: 하트 버튼(옵션)
                  if (showHeart)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: _CircleIconButton(
                        icon: Icons.favorite_border,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('북마크에 저장완료! (mock)'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // 2) 콘텐츠 영역
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 + 평점(옵션)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          data.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (rating != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Color(0xFFFFC107),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${rating!.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 메타: 주소 • 거리 • 시간 (옵션)
                  Row(
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: 14,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _shortAddr(data.addr1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                      if ((distance ?? '').isNotEmpty) ...[
                        const SizedBox(width: 6),
                        const Text(
                          '•',
                          style: TextStyle(color: Colors.black26),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          distance!,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                      if ((duration ?? '').isNotEmpty) ...[
                        const SizedBox(width: 6),
                        const Text(
                          '•',
                          style: TextStyle(color: Colors.black26),
                        ),
                        const SizedBox(width: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              duration!,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  // (옵션) 간단 설명을 붙이고 싶다면 여기에 Text(...) 추가
                  if ((tags ?? const []).isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags!
                          .take(4)
                          .map((t) => _TagChip(text: t))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 가로형 카드(기존 유지) — 필요 시 사용
  // ---------------------------------------------------------------------------
  Widget _buildHorizontal(BuildContext context) {
    final radius = BorderRadius.circular(12);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ExploreDetailScreen(data: data)),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: thumbnailWidth,
              child: Hero(
                tag: 'place:${data.contentid}',
                child: Image.network(
                  data.firstimage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.network(
                    'https://cdn.pixabay.com/photo/2019/07/08/04/23/traveling-4323759_1280.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          size: 14,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _shortAddr(data.addr1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
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

// ----------------------------------------------------------------------------
// 작은 UI 파츠: 칩/태그/아이콘 버튼
// ----------------------------------------------------------------------------
class _BadgeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BadgeChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black87),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final String text;
  const _BadgePill({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;
  const _TagChip({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(999),
        color: Colors.white,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Colors.black87),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
      ),
    );
  }
}
