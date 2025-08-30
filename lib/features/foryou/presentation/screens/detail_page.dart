// lib/features/foryou/presentation/screens/detail_page.dart
// ============================================================================
// CategoryDetailPage — ForYou 상세 화면 (디자인 리뉴얼 버전)
// ----------------------------------------------------------------------------
// ✅ 유지한 것
//  - Stopwatch로 체류시간 추적, dispose()에서 VM.markBounced / VM.finishDetail 호출
//  - 화면 시그니처(CategoryDetailPage(category, contextModel)) 그대로
//
// 🎨 바꾼 것 (웹 시안 반영)
//  - 상단: 뒤로가기 + 이모지/제목 + 랭크/점수 뱃지 영역 + 공유/북마크
//  - 카테고리 설명 카드(그라디언트)
//  - 통계 카드 3개 (추천 장소/관련 다이어리/점수)
//  - Masonry(핀터레스트형) 추천 콘텐츠 그리드 (2~3열 반응형)
//  - 카드: 상단 이미지 + 좌상단 카테고리/가격 배지(더 작고 연한 스타일) +
//          우상단 하트/가격 + 하단 제목/메타/태그(컴팩트)
//  - 카드 외곽선 제거(윤곽선 없이 깨끗한 카드)
//
// ⚠️ 데이터는 "디자인만" 반영 — 아래 _getMock* 함수로 샘플 제공
//    실제 연결 시, API/VM 데이터를 주입해 해당 모델로 바꾸면 됨.
//
// 📦 의존: flutter_staggered_grid_view: ^0.7.0
//    pubspec.yaml에 추가 후 flutter pub get
// ============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import 'package:heat_trip_flutter/features/foryou/domain/entities/context.dart'
    as dom;
import '../states/foryou_vm.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 화면 위젯
// ─────────────────────────────────────────────────────────────────────────────
class CategoryDetailPage extends StatefulWidget {
  final String category;
  final dom.Context contextModel;

  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.contextModel,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late final Stopwatch _sw;

  @override
  void initState() {
    super.initState();
    _sw = Stopwatch()..start();
  }

  @override
  void dispose() {
    _sw.stop();
    if (_sw.elapsedMilliseconds < 1500) {
      context.read<ForYouVM>().markBounced(widget.category);
    }
    context.read<ForYouVM>().finishDetail(widget.category, widget.contextModel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    // ── 디자인 시안처럼: 헤더 + 설명/통계 + 추천 콘텐츠(Masonry)
    final mockDest = _getMockDestinations(widget.category);
    final mockDiary = _getMockDiaryPosts(widget.category);
    final List<Object> allItems = [...mockDiary, ...mockDest];

    // 열 개수: 폰 2, 태블릿 3
    final crossAxisCount = width >= 900 ? 3 : 2;
    const spacing = 8.0; // 카드 간격(좁게)

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ───────────────────────────────────────────────────────────── AppBar
          // 기존 SliverAppBar 부분 교체
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            // 기본 뒤로가기를 쓰도록 허용
            automaticallyImplyLeading: true,
            titleSpacing: 0,
            title: Row(
              children: [
                // ⛔️ 여기 있던 커스텀 IconButton(Icons.arrow_back) 제거!
                // const SizedBox(width: 4), // 필요하면 살짝 여백만 둘 수도 있어요

                // 이모지 + 제목 + 랭크/점수
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        _guessEmoji(widget.category),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                _badge(
                                  context,
                                  text: '#1위',
                                  small: true,
                                  filled: false,
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.trending_up,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '+12,340',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark_border),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ───────────────────────────────────────────────────────────── 헤더/설명
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  // 설명 카드(그라디언트)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [
                          cs.primary.withOpacity(0.08),
                          cs.secondary.withOpacity(0.08),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Text(
                      '이 카테고리는 현재 컨텍스트(P:${widget.contextModel.P}, '
                      'A:${widget.contextModel.A}, D:${widget.contextModel.D})와 잘 맞는 추천이에요. '
                      '선호(사교:${_yn(widget.contextModel.sociality)}, '
                      '소음:${_yn(widget.contextModel.noise)}, '
                      '혼잡:${_yn(widget.contextModel.crowdedness)}) 및 '
                      '위치(${widget.contextModel.location.toUpperCase()}) 신호를 반영했습니다.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 통계 3개
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          context,
                          value: '${mockDest.length}',
                          label: '추천 장소',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statCard(
                          context,
                          value: '${mockDiary.length}',
                          label: '관련 다이어리',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statCard(
                          context,
                          value: '12,340',
                          label: '인기도 점수',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ───────────────────────────────────────────────────────────── 섹션 타이틀
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    '추천 콘텐츠',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${allItems.length}개 항목',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          // ───────────────────────────────────────────────────────────── Masonry
          // 외곽과의 틈을 최소화하려면 좌우 패딩을 12 → 8 또는 0으로 줄여도 됨
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childCount: allItems.length,
              itemBuilder: (context, i) {
                // 1) 현재 카드의 원본 데이터
                final Object data = allItems[i];

                // 2) 각 카드의 이미지 높이(가변) — id 해시 기반으로 3단계 랜덤 느낌
                final tileW =
                    (width - 24 - spacing * (crossAxisCount - 1)) /
                    crossAxisCount;
                final String itemId = _getItemId(data);
                final double imgH = _estimateHeight(tileW, itemId);

                // 3) 카드 반환
                return _ContentCard(item: data, imageHeight: imgH);
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ),
    );
  }

  String _yn(int v) => v == 1 ? '예' : '아니오';

  String _guessEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('카페') || lower.contains('cafe')) return '☕️';
    if (lower.contains('공원') || lower.contains('park')) return '🌳';
    if (lower.contains('축제') || lower.contains('festival')) return '🎪';
    return '✨';
  }

  Widget _statCard(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(
    BuildContext context, {
    required String text,
    bool small = false,
    bool filled = false,
  }) {
    final bg = filled
        ? Theme.of(context).colorScheme.primary.withOpacity(0.14)
        : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8);
    final fg = filled
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.0,
        ),
      ),
    );
  }

  // 주어진 item(Object)이 어떤 타입이든 id 문자열을 안전하게 꺼냄
  String _getItemId(Object data) {
    if (data is _DiaryPost) return data.id;
    return (data as _LocalDestination).id;
  }

  // Masonry용 간단 높이 추정 (id 해시 기반으로 3단계)
  double _estimateHeight(double tileWidth, String id) {
    final bucket = id.hashCode.abs() % 3;
    const ratios = [0.75, 1.0, 1.35];
    return tileWidth * ratios[bucket];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 내부용 모델 + 더미 데이터 (디자인 시연용)
// 실제 연결 시, 프로젝트 모델/API로 교체하면 됩니다.
// ─────────────────────────────────────────────────────────────────────────────
class _LocalDestination {
  final String id;
  final String name;
  final String type; // 'cafe' | 'park' | ...
  final String description;
  final String imageUrl;
  final String distance;
  final double rating;
  final String price; // '$' | '$$' | '$$$'
  final List<String> tags;
  final String neighborhood;
  final bool isPopular;
  final bool isNew;

  _LocalDestination({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.imageUrl,
    required this.distance,
    required this.rating,
    required this.price,
    required this.tags,
    required this.neighborhood,
    this.isPopular = false,
    this.isNew = false,
  });
}

class _DiaryPost {
  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final int likes;
  final int comments;
  final bool isLiked;
  final List<String> tags;

  _DiaryPost({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.tags,
  });
}

List<_LocalDestination> _getMockDestinations(String categoryId) => [
  _LocalDestination(
    id: '1',
    name: '숨겨진 정원 카페',
    type: 'cafe',
    description: '조용한 골목에 위치한 아늑한 정원 카페',
    imageUrl:
        'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=1080&q=80',
    distance: '0.8km',
    rating: 4.7,
    price: '\$\$',
    tags: ['조용함', '자연', '인스타그램'],
    neighborhood: '서촌',
    isNew: true,
  ),
  _LocalDestination(
    id: '2',
    name: '한강 피크닉 스팟',
    type: 'park',
    description: '탁 트인 강변에서 친구들과 함께 즐기는 피크닉',
    imageUrl:
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1080&q=80',
    distance: '1.2km',
    rating: 4.5,
    price: '\$',
    tags: ['활동적', '자연', '단체'],
    neighborhood: '한강공원',
    isPopular: true,
  ),
  _LocalDestination(
    id: '3',
    name: '전통 찻집 "담소"',
    type: 'cafe',
    description: '전통 한옥에서 즐기는 정통 차 문화',
    imageUrl:
        'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=1080&q=80',
    distance: '0.5km',
    rating: 4.8,
    price: '\$\$',
    tags: ['전통', '차분함', '문화'],
    neighborhood: '인사동',
  ),
];

List<_DiaryPost> _getMockDiaryPosts(String categoryId) => [
  _DiaryPost(
    id: 'd1',
    title: '서촌의 숨겨진 보석, 작은 책방 카페',
    location: '서촌',
    imageUrl:
        'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=1080&q=80',
    likes: 24,
    comments: 8,
    isLiked: false,
    tags: ['서촌', '책방카페', '라벤더라떼', '힐링'],
  ),
  _DiaryPost(
    id: 'd2',
    title: '한강에서의 피크닉 데이',
    location: '한강공원',
    imageUrl:
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1080&q=80',
    likes: 42,
    comments: 15,
    isLiked: true,
    tags: ['한강', '피크닉', '친구', '맥주'],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// 카드 위젯 (세로형, Masonry 대응)
// ─────────────────────────────────────────────────────────────────────────────
class _ContentCard extends StatelessWidget {
  final Object item; // _LocalDestination | _DiaryPost
  final double imageHeight;

  const _ContentCard({required this.item, required this.imageHeight});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final cs = Theme.of(context).colorScheme;

    // ── 타입 분기: diary vs destination
    final bool isDiary = item is _DiaryPost;
    final String imageUrl = isDiary
        ? (item as _DiaryPost).imageUrl
        : (item as _LocalDestination).imageUrl;
    final String title = isDiary
        ? (item as _DiaryPost).title
        : (item as _LocalDestination).name;
    final String meta = isDiary
        ? (item as _DiaryPost).location
        : '${(item as _LocalDestination).neighborhood} • ${(item as _LocalDestination).distance}';
    final List<String> tags = isDiary
        ? (item as _DiaryPost).tags
        : (item as _LocalDestination).tags;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide.none, // 외곽선 제거
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 이미지 + 오버레이
            SizedBox(
              height: imageHeight,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: cs.surfaceVariant),
                    ),
                  ),

                  // 좌상단 배지(작고 연하게)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _badgeChip(
                      icon: isDiary ? Icons.person : Icons.local_cafe_outlined,
                      label: isDiary
                          ? '다이어리'
                          : _typeLabel((item as _LocalDestination).type),
                      small: true,
                      muted: true,
                    ),
                  ),

                  // 우상단 하트/가격
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        _circleIcon(
                          context,
                          icon: Icons.favorite_border,
                          onTap: () {},
                        ),
                        if (!isDiary) const SizedBox(width: 6),
                        if (!isDiary)
                          _pricePill((item as _LocalDestination).price),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 본문
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 + (옵션) 평점
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!isDiary) ...[
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          (item as _LocalDestination).rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 메타: 위치/거리
                  Row(
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: 12,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 태그 (최대 3개)
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: tags.take(3).map((t) => _tagChip(t)).toList(),
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

  // 작은 배지
  Widget _badgeChip({
    required IconData icon,
    required String label,
    bool small = false,
    bool muted = false,
  }) {
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

  // 가격 pill
  Widget _pricePill(String text) {
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

  // 원형 아이콘 버튼
  Widget _circleIcon(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, size: 16, color: Colors.black87),
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'cafe':
        return '카페';
      case 'park':
        return '공원';
      case 'restaurant':
        return '맛집';
      case 'shopping':
        return '쇼핑';
      case 'cultural':
        return '문화';
      case 'entertainment':
        return '엔터';
      default:
        return '기타';
    }
  }

  Widget _tagChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(999),
        color: Colors.white,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10.5, color: Colors.black87),
      ),
    );
  }
}
