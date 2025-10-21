import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:heat_trip_flutter/features/foryou_v2/state/foryou_vm.dart';
import 'package:heat_trip_flutter/features/foryou_v2/domain/models.dart';
import 'package:heat_trip_flutter/features/foryou_v2/presentation/widgets/place_tile.dart';

class ResultsScreen extends StatefulWidget {
  final ForYouVM vm;
  const ResultsScreen({super.key, required this.vm});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String sortBy = 'distance'; // 'distance' | 'match'
  String viewMode = 'grid'; // 'grid' | 'list'

  static const _bg = Colors.white;
  static const _divider = Color(0xFFE6E6EA);

  @override
  Widget build(BuildContext context) {
    final places = [...widget.vm.places];

    // 정렬
    places.sort((a, b) {
      if (sortBy == 'distance') {
        final ad = a.distanceKm ?? 1e9;
        final bd = b.distanceKm ?? 1e9;
        return ad.compareTo(bd);
      }
      return b.finalScore.compareTo(a.finalScore);
    });

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bg,
        foregroundColor: Colors.black,
        title: const Text(
          '추천 여행지',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: sortBy,
            onSelected: (v) => setState(() => sortBy = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'distance', child: Text('거리순')),
              PopupMenuItem(value: 'match', child: Text('매칭률순')),
            ],
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            tooltip: viewMode == 'grid' ? '리스트 보기' : '그리드 보기',
            icon: Icon(viewMode == 'grid' ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() {
              viewMode = (viewMode == 'grid') ? 'list' : 'grid';
            }),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _divider),
        ),
      ),
      body: places.isEmpty
          ? const Center(child: Text('추천 장소가 없습니다.'))
          : (viewMode == 'grid'
                ? _Grid(places: places, onTapPlace: _goDetail)
                : _List(places: places, onTapPlace: _goDetail)),
    );
  }

  void _goDetail(BuildContext context, Place p) {
    final contentTypeId = p.contentTypeId ?? 12; // 기본 관광지
    context.pushNamed(
      'explore_detail', // explore_routes.dart 에 등록된 이름
      pathParameters: {
        'contentId': '${p.placeId}',
        'contentTypeId': '$contentTypeId',
      },
      extra: p.firstImageUrl, // 상세 갤러리 fallback
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// Grid 래퍼 (화면 가장자리까지 붙는 간격)
class _Grid extends StatelessWidget {
  final List<Place> places;
  final void Function(BuildContext, Place) onTapPlace;
  const _Grid({required this.places, required this.onTapPlace});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      itemCount: places.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 258,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (_, i) => _GridCard(
        place: places[i],
        onTap: () => onTapPlace(context, places[i]),
      ),
    );
  }
}

/// 리스트 래퍼
class _List extends StatelessWidget {
  final List<Place> places;
  final void Function(BuildContext, Place) onTapPlace;
  const _List({required this.places, required this.onTapPlace});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      itemCount: places.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, i) => PlaceTile(
        place: places[i],
        onTap: () => onTapPlace(context, places[i]),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// Grid 전용 카드
/// - 그림자 0
/// - 흰색 배경 + 진한 외곽선
/// - 카테고리/거리 분리
/// - 매칭 배지: **단일 색(파스텔 레드 계열) 외곽선만**, 배경 흰색, 텍스트 짙은 회색
class _GridCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;
  const _GridCard({required this.place, required this.onTap});

  static const _radius = 14.0;
  static const _cardBorder = Color(0xFFCACAD3); // 카드 외곽
  static const _muted = Color(0xFF555661); // 텍스트 짙은 회색

  // 파스텔 레드(형광X)
  static const _pillBorder = Color(0xFFE07A7A); // 외곽만 컬러
  static const _pillText = Color(0xFF2B2B34); // 배지 텍스트(짙은 회색)

  static const _PLACEHOLDER =
      'https://placehold.co/1200x800/F5F6F8/9AA0A6?text=%EC%9D%B4%EB%AF%B8%EC%A7%80%20%EC%97%86%EC%9D%8C&font=inter';

  @override
  Widget build(BuildContext context) {
    final cat = (place.cat3Name ?? place.cat3Code);
    final dist = place.distanceKm != null
        ? '${place.distanceKm!.toStringAsFixed(1)}km'
        : null;

    // 표시는 반올림 정수로 통일
    final int pct = ((place.finalScore * 100)).round().clamp(0, 100);

    final String url = (place.firstImageUrl ?? '').isNotEmpty
        ? place.firstImageUrl!
        : _PLACEHOLDER;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_radius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _cardBorder, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 썸네일
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_radius),
                topRight: Radius.circular(_radius),
              ),
              child: AspectRatio(
                aspectRatio: 1.2,
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.network(
                    _PLACEHOLDER,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF3F3F6),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFFB8B8C3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 본문
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 + 매칭 뱃지
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5, // 타이틀 더 축소
                            height: 1.18,
                          ),
                        ),
                      ),
                      _OutlinePill(
                        text: '매칭 ${pct}%',
                        borderColor: _pillBorder,
                        textColor: _pillText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 카테고리
                  Text(
                    cat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12.5,
                      height: 1.2,
                    ),
                  ),
                  // 거리(있을 때만 한 줄 아래)
                  if (dist != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: _muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dist,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 12.5,
                            height: 1.2,
                          ),
                        ),
                      ],
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
}

class _OutlinePill extends StatelessWidget {
  final String text;
  final Color borderColor;
  final Color textColor;

  const _OutlinePill({
    required this.text,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white, // 배경 흰색 고정
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1.2), // 외곽선만 컬러
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: textColor, // 짙은 회색
          height: 1.0,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
