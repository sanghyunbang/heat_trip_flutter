// =============================
// place_card.dart — Vertical card (masonry-ready, compact) + Horizontal card
// =============================

import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';
import 'package:heat_trip_flutter/features/explore/presentation/screens/explore_detail_screen.dart';

enum PlaceCardLayout { horizontal, vertical }

class PlaceCard extends StatelessWidget {
  // 필수
  final PlaceItem data;

  // 레이아웃/스타일
  final PlaceCardLayout layout;
  final double? imageHeight;
  final bool compact;

  // 메타(옵션)
  final String? categoryLabel;
  final String? priceLabel;
  final double? rating;
  final String? distance;
  final String? duration;
  final List<String>? tags;
  final bool showHeart;

  // 가로형
  final double thumbnailWidth;

  // 튜닝 파라미터
  final double outerRadius; // 큰 박스 라운드
  final double imageCornerRadius; // 이미지 라운드(위·아래)
  final double imageElevation; // 이미지만 얕은 그림자
  final double barImageGap; // Top Bar ↔ 이미지 간격(작게)
  final bool showTopBar; // 상단 바 사용 여부
  final EdgeInsets topBarPadding; // 상단 바 패딩(좌우 좁게)

  const PlaceCard({
    super.key,
    required this.data,
    this.layout = PlaceCardLayout.vertical,
    this.imageHeight,
    this.compact = false,
    this.categoryLabel,
    this.priceLabel,
    this.rating,
    this.distance,
    this.duration,
    this.tags,
    this.showHeart = true,
    this.thumbnailWidth = 160,

    // 기본값(요구 반영)
    this.outerRadius = 12,
    this.imageCornerRadius = 1, // 이미지 곡선이 외곽과 일치
    this.imageElevation = 1,
    this.barImageGap = 4, // 이미지에 "더 붙게" 아주 좁게
    this.showTopBar = true,
    this.topBarPadding = const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 6,
    ),
  });

  // 축약 주소
  String _shortAddr(String? addr) {
    if (addr == null) return '';
    final t = addr.trim();
    if (t.isEmpty) return '';
    final parts = t.split(RegExp(r'\s+'));
    return parts.length >= 2 ? '${parts[0]} ${parts[1]}' : t;
  }

  String get _cat => (categoryLabel ?? '').trim();
  String? get _priceOpt {
    final s = (priceLabel ?? '').trim();
    return s.isEmpty ? null : s;
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

  // ───────────────────────────────────────────────────────────────────────────
  // 세로형: [Outer(라운드+외곽선)] → [TopBar(상단만 라운드)] → [Image(위·아래 라운드)] → [Content]
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildVertical(BuildContext context) {
    // compact 치수
    final double pad = compact ? 8 : 12;
    final double titleSize = compact ? 13 : 16;
    final double titleHeight = compact ? 1.1 : 1.2;
    final double gapSm = compact ? 4 : 6;
    final double metaIcon = compact ? 12 : 14;
    final double metaFont = compact ? 11 : 12;
    final double rateIcon = compact ? 14 : 16;

    final outline = Theme.of(context).colorScheme.outlineVariant;
    final imgRadius = BorderRadius.circular(imageCornerRadius);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(outerRadius),
        side: BorderSide.none,
      ),
      clipBehavior: Clip.none,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ExploreDetailScreen(data: data)),
          );
        },
        child: Container(
          // ★ 큰 박스: 라운드 + 얇은 외곽선
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: outline, width: 1),
            borderRadius: BorderRadius.circular(outerRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // [0] Top Bar — 상단 모서리만 라운드, 카테고리/하트 끝으로 밀착
              if (showTopBar)
                Container(
                  padding: topBarPadding,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(outerRadius),
                      topRight: Radius.circular(outerRadius),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // ← 좌우 끝으로
                    children: [
                      // 좌: 카테고리(없으면 자리 비움)
                      if (_cat.isNotEmpty)
                        _BadgeChip(
                          icon: Icons.local_cafe_outlined,
                          label: _cat,
                          small: true,
                          muted: false, // 상단바에서는 선명하게
                        )
                      else
                        const SizedBox.shrink(),

                      // 우: (가격 옵션) + 하트
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_priceOpt != null) ...[
                            _BadgePill(text: _priceOpt!),
                            const SizedBox(width: 8),
                          ],
                          if (showHeart)
                            _CircleIconButton(
                              icon: Icons.favorite_border,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('북마크에 저장 완료! (mock)'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Top Bar ↔ 이미지 간격: 매우 좁게
              if (barImageGap > 0) SizedBox(height: barImageGap),

              // [1] 이미지 — 위·아래 모두 라운드 + 얕은 그림자
              _imageBox(
                child: PhysicalModel(
                  color: Colors.white,
                  elevation: imageElevation,
                  borderRadius: imgRadius,
                  clipBehavior: Clip.antiAlias,
                  child: Hero(
                    tag: 'place:${data.contentid}',
                    child: Image.network(
                      data.firstimage,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Image.network(
                        'https://cdn.pixabay.com/photo/2019/07/08/04/23/traveling-4323759_1280.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              // 이미지 ↔ 콘텐츠 간격: 0 (flush). 필요시 padding으로 제어
              // [2] 콘텐츠 — 외곽선 없이 이미지에 바로 붙음
              Padding(
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 + 평점
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
                                color: const Color(0xFFFFC107),
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

                    // 메타: 주소 • 거리 • 시간
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
                        if ((distance ?? '').trim().isNotEmpty) ...[
                          const SizedBox(width: 6),
                          const Text(
                            '•',
                            style: TextStyle(color: Colors.black26),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            distance!.trim(),
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: metaFont,
                            ),
                          ),
                        ],
                        if ((duration ?? '').trim().isNotEmpty) ...[
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
                                duration!.trim(),
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

                    // 태그(옵션)
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
      ),
    );
  }

  /// Masonry 대응: 세로형 이미지 박스
  Widget _imageBox({required Widget child}) {
    if (imageHeight != null) {
      return SizedBox(height: imageHeight, child: child);
    }
    return AspectRatio(aspectRatio: 16 / 9, child: child);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 가로형
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildHorizontal(BuildContext context) {
    final radius = BorderRadius.circular(imageCornerRadius);

    return Card(
      margin: EdgeInsets.zero,
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
              child: ClipRRect(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(imageCornerRadius),
                ),
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

// ─────────────────────────────────────────────────────────────────────────────
// 작은 파츠
// ─────────────────────────────────────────────────────────────────────────────

class _BadgeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool small;
  final bool muted;

  const _BadgeChip({
    required this.icon,
    required this.label,
    this.small = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
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
  final bool small;
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // 상단바와 자연스럽게
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.favorite_border, size: 20, color: Colors.black87),
        ),
      ),
    );
  }
}
