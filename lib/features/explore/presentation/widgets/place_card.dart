// =============================
// place_card.dart — Vertical card (masonry-ready, compact) + Horizontal card
// =============================
// 목적
// - 상단 큰 이미지 + 하단 정보(제목/주소/태그...) 형태의 "세로형 카드" 기본 제공
// - Masonry(핀터레스트형) 레이아웃을 위한 "가변 이미지 높이" 지원(imageHeight)
// - 하단 정보를 대폭 축소하는 compact 모드 지원(compact: true)
// - Horizontal(좌측 썸네일) 카드도 유지
//
// 사용 예
// - 기본 세로형: PlaceCard(data: item)
// - Masonry(가변 높이): PlaceCard(data: item, imageHeight: 220)
// - 더 콤팩트하게: PlaceCard(data: item, imageHeight: 220, compact: true)
// - 가로형: PlaceCard(data: item, layout: PlaceCardLayout.horizontal)

import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';
import 'package:heat_trip_flutter/features/explore/presentation/screens/explore_detail_screen.dart';

/// 두 가지 카드 레이아웃 모드
enum PlaceCardLayout { horizontal, vertical }

/// 장소 카드를 표시하는 공통 위젯
///
/// - [layout] 으로 세로/가로 레이아웃 선택
/// - [imageHeight] 로 Masonry용 가변 이미지 높이 지정(세로형에서만 사용)
/// - [compact] 로 하단 텍스트 블록을 매우 작게 표시
/// - 나머지 라벨/태그/평점 등은 "옵션"으로 주면 나타나고, 없으면 깔끔히 감춤
class PlaceCard extends StatelessWidget {
  // ---------------------------
  // 필수 데이터 (DTO)
  // ---------------------------
  final PlaceItem data;

  // ---------------------------
  // 레이아웃/스타일 옵션
  // ---------------------------
  final PlaceCardLayout layout;

  /// Masonry(벽돌) 레이아웃 대응을 위한 "이미지 고정 높이"
  /// - null 이면 16:9 AspectRatio를 사용(기본)
  /// - 값이 있으면 SizedBox(height: imageHeight)로 렌더
  final double? imageHeight;

  /// 하단 텍스트/간격을 대폭 줄이는 모드
  final bool compact;

  // ---------------------------
  // 표시용 메타(옵션)
  // ---------------------------
  final String? categoryLabel; // 예: '카페'
  final String? priceLabel; // 예: '$$' 또는 '₩₩'
  final double? rating; // 예: 4.8
  final String? distance; // 예: '0.5km'
  final String? duration; // 예: '1-2시간'
  final List<String>? tags; // 예: ['전통','차분함','문화']
  final bool showHeart; // 우하단 하트 표시 여부(북마크 느낌)

  // ---------------------------
  // 가로형 전용 옵션
  // ---------------------------
  final double thumbnailWidth; // 좌측 썸네일 폭

  const PlaceCard({
    super.key,
    required this.data,
    this.layout = PlaceCardLayout.vertical, // 기본: 세로형
    this.imageHeight, // Masonry 핵심
    this.compact = false, // 하단 영역 축소 여부
    this.categoryLabel,
    this.priceLabel,
    this.rating,
    this.distance,
    this.duration,
    this.tags,
    this.showHeart = true,
    this.thumbnailWidth = 160,
  });

  // 주소(도로명/지번 등)를 "시/구" 정도로 짧게 잘라 표시
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
  // 세로형 카드
  // - 상단: 이미지(AspectRatio 16:9 또는 imageHeight 고정) + 오버레이(배지/하트/가격)
  // - 하단: 제목, 주소/거리/시간, 평점, 태그(옵션)
  // ---------------------------------------------------------------------------
  Widget _buildVertical(BuildContext context) {
    final radius = BorderRadius.circular(16);

    // compact 모드에서 사용할 치수/폰트 변수
    final double pad = compact ? 8 : 12; // 하단 패딩
    final double titleSize = compact ? 13 : 16; // 제목 폰트
    final double titleHeight = compact ? 1.1 : 1.2;
    final double gapSm = compact ? 4 : 6; // 요소 간격
    final double metaIcon = compact ? 12 : 14; // 메타 아이콘
    final double metaFont = compact ? 11 : 12; // 메타 텍스트
    final double rateIcon = compact ? 14 : 16; // 별 아이콘

    return Card(
      margin: EdgeInsets.zero, // 외부 여백 없음
      elevation: 0, // 그림자 제거(모던 납작 카드)
      shadowColor: Colors.transparent,
      color: Colors.white,
      surfaceTintColor: Colors.transparent, // M3 틴트 제거(회색 끼 방지)
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant, // 미세한 외곽선
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias, // 모서리 라운드에 맞게 자름
      child: InkWell(
        onTap: () {
          // 상세 화면으로 전환 (Hero로 부드러운 전환)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ExploreDetailScreen(data: data)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) 이미지 영역: Masonry면 imageHeight를 그대로, 아니면 16:9 유지
            _imageBox(
              child: Stack(
                children: [
                  // 실제 이미지
                  Positioned.fill(
                    child: Hero(
                      tag: 'place:${data.contentid}', // 태그 유일성 보장 필요
                      child: Image.network(
                        data.firstimage,
                        fit: BoxFit.cover,
                        // 로딩 실패 시 대체 이미지
                        errorBuilder: (context, error, stackTrace) => Image.network(
                          'https://cdn.pixabay.com/photo/2019/07/08/04/23/traveling-4323759_1280.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // 좌상단: 카테고리 배지(옵션)
                  if ((categoryLabel ?? '').isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _BadgeChip(
                        icon: Icons.local_cafe_outlined,
                        label: categoryLabel!,
                        small: true,
                        muted: true,
                      ),
                    ),

                  // 우상단: 가격/라벨 배지(옵션)
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
                          // TODO: 실제 즐겨찾기/저장 로직 연결
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('북마크에 저장 완료! (mock)'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // 2) 콘텐츠 영역 (compact면 전체적으로 작게)
            Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 + (옵션) 평점
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          data.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                            height: titleHeight,
                          ),
                        ),
                      ),
                      if (rating != null)
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: rateIcon,
                              color: const Color(0xFFFFC107), // 머터리얼 앰버
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: gapSm),

                  // 메타: 주소 • 거리 • 시간(옵션)
                  Row(
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: metaIcon,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _shortAddr(data.addr1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: metaFont,
                          ),
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
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: metaFont,
                          ),
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
                            Icon(
                              Icons.schedule,
                              size: metaIcon,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              duration!,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: metaFont,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  // 태그(옵션): 최대 4개 — compact면 칩도 소형
                  if ((tags ?? const []).isNotEmpty) ...[
                    SizedBox(height: compact ? 6 : 10),
                    Wrap(
                      spacing: compact ? 4 : 6,
                      runSpacing: compact ? 4 : 6,
                      children: tags!
                          .take(4)
                          .map((t) => _TagChip(text: t, small: compact))
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

  /// Masonry 대응: 세로형 이미지 박스
  /// - [imageHeight] 가 있으면 명시 높이로, 없으면 16:9 비율로.
  Widget _imageBox({required Widget child}) {
    if (imageHeight != null) {
      return SizedBox(height: imageHeight, child: child);
    }
    return AspectRatio(aspectRatio: 16 / 9, child: child);
  }

  // ---------------------------------------------------------------------------
  // 가로형 카드 — 좌측 썸네일 + 우측 텍스트
  // ---------------------------------------------------------------------------
  Widget _buildHorizontal(BuildContext context) {
    final radius = BorderRadius.circular(12);

    return Card(
      margin: EdgeInsets.zero, // 외부 여백 없음
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
            // 좌측 썸네일
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
            // 우측 텍스트
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
// 작은 UI 파츠: 배지/태그/아이콘 버튼
// ----------------------------------------------------------------------------

/// 좌상단 작은 배지(아이콘 + 라벨)
/// 좌상단 작은 배지(아이콘 + 라벨) — small/muted 지원
class _BadgeChip extends StatelessWidget {
  final IconData icon;
  final String label;

  /// 더 작게 렌더링할지
  final bool small;

  /// 연한 톤(텍스트/아이콘/배경 모두 옅게)
  final bool muted;

  const _BadgeChip({
    required this.icon,
    required this.label,
    this.small = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    // 사이즈/톤 계산
    final double padH = small ? 7 : 8;
    final double padV = small ? 3 : 4;
    final double iconSize = small ? 12 : 14;
    final double fontSize = small ? 10 : 11;

    final Color fg = Colors.black.withOpacity(muted ? 0.58 : 0.87);
    final Color bg = Colors.white.withOpacity(muted ? 0.70 : 0.92);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        // 톤을 연하게 보이게 하려면 그림자 제거/약화
        boxShadow: muted
            ? const []
            : const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: fg,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

/// 우상단 가격/라벨 pill
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

/// 해시태그/속성 태그 (얇은 테두리 + 라운드)
class _TagChip extends StatelessWidget {
  final String text;
  final bool small; // compact 모드에서 더 작게 그리기
  const _TagChip({required this.text, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(999),
        color: Colors.white,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: small ? 10 : 11, color: Colors.black87),
      ),
    );
  }
}

/// 우하단 원형 아이콘 버튼(하트 등)
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
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(Icons.favorite_border, size: 18, color: Colors.black87),
        ),
      ),
    );
  }
}
