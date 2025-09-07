/// explore_detail_screen.dart
/// ─────────────────────────────────────────────────────────────────────────
/// 역할
/// - DetailVM 상태 구독 (로딩/에러/성공)
/// - 로딩/에러에서도 항상 '뒤로가기'를 보장 (FallbackAppBar)
/// - 성공 시: SliverAppBar + 섹션 위젯들 조립
/// - 네비게이션 안전 팝(safePop) 제공 (go_router/일반 Navigator 모두 대응)
/// ─────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entity_detail/place_detail.dart';
import '../state/detail_vm.dart';

// 섹션 위젯들 (프레젠테이션 분리)
import '../widgets_detail/detail_appbars.dart';
import '../widgets_detail/header_info.dart';
import '../widgets_detail/gallery.dart';
import '../widgets_detail/contact_card.dart';
import '../widgets_detail/hours_card.dart';
import '../widgets_detail/amenities_card.dart';
import '../widgets_detail/reviews_card.dart';
import '../widgets_detail/strip_html.dart';

class ExploreDetailScreen extends StatefulWidget {
  final int contentId; // 상세 API 키
  final int contentTypeId; // 타입(관광지, 숙박 등) → 하위 섹션 구성이 달라질 때 사용

  const ExploreDetailScreen({
    super.key,
    required this.contentId,
    required this.contentTypeId,
  });

  @override
  State<ExploreDetailScreen> createState() => _ExploreDetailScreenState();
}

class _ExploreDetailScreenState extends State<ExploreDetailScreen> {
  // 갤러리 인덱스, 즐겨찾기 토글 등 'UI 로컬 상태'
  int _galleryIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    // VM 데이터 로드 트리거를 스케줄 (build 전 안전 실행)
    // [1] 여기에서 부터 시작!
    Future.microtask(() {
      context.read<DetailVM>().load(
        contentId: widget.contentId,
        contentTypeId: widget.contentTypeId,
      );
    });
  }

  /// go_router 또는 일반 Navigator를 모두 고려한 안전한 뒤로가기
  /// - 스택이 있으면 pop
  /// - 없으면 '/explore'로 이동
  void _safePop() {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      context.go('/explore');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailVM>(); // DetailVM 상태 구독

    // 1) 로딩 상태: 상단 AppBar + 인디케이터 (뒤로가기 보장)
    if (vm.loading) {
      return Scaffold(
        appBar: FallbackAppBar(titleText: '로딩 중…', onBack: _safePop),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 2) 에러 상태: 에러 메시지 + 다시 시도 버튼 (뒤로가기 보장)
    if (vm.error != null) {
      return Scaffold(
        appBar: FallbackAppBar(titleText: '오류', onBack: _safePop),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('오류가 발생했습니다.\n${vm.error}', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.read<DetailVM>().load(
                    contentId: widget.contentId,
                    contentTypeId: widget.contentTypeId,
                  ),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3) 성공 상태 데이터
    final PlaceDetail? detail = vm.data;
    if (detail == null) {
      // 방어 코드: 데이터 없을 때도 뒤로가기 보장
      return Scaffold(
        appBar: FallbackAppBar(titleText: '상세', onBack: _safePop),
        body: const SizedBox.shrink(),
      );
    }

    // 대표 이미지 + 추가 이미지 병합 (중복 제거)
    final images = <String>[
      if ((detail.firstImage ?? '').isNotEmpty) detail.firstImage!,
      ...detail.images,
    ].toSet().toList();

    // 4) 성공 UI: 확장 SliverAppBar + 섹션 조립
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // (A) 상단 확장 앱바: 갤러리/공유/하트/뒤로가기
          // SliverDetailAppBar(
          //   title: detail.title,
          //   isFavorite: _isFavorite,
          //   onBack: _safePop,
          //   onToggleFavorite: () => setState(() => _isFavorite = !_isFavorite),
          //   gallery: Gallery(
          //     images: images,
          //     index: _galleryIndex,
          //     onChanged: (i) => setState(() => _galleryIndex = i),
          //   ),
          // ),
          // (A) 상단 확장 앱바: 갤러리/공유/하트/뒤로가기 — 제목 오버레이 없음
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _safePop,
            ),
            actions: [
              IconButton(
                icon: _isFavorite
                    ? const Icon(Icons.favorite)
                    : const Icon(Icons.favorite_border),
                onPressed: () => setState(() => _isFavorite = !_isFavorite),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {}, // 공유 액션
              ),
            ],
            // FlexibleSpaceBar.title을 절대 주지 않습니다 → 이미지 위 텍스트가 사라짐
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Gallery(
                images: images,
                index: _galleryIndex,
                onChanged: (i) => setState(() => _galleryIndex = i),
              ),
            ),
          ),

          // (B) 본문 섹션들
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeaderInfo(detail: detail),
                    const SizedBox(height: 12),

                    // 개요 (HTML 문자열은 stripHtml로 정리)
                    if ((detail.overview ?? '').isNotEmpty) ...[
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        '개요',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(stripHtml(detail.overview!)),
                    ],

                    const SizedBox(height: 16),
                    ContactCard(detail: detail),
                    const SizedBox(height: 12),
                    HoursCard(hours: detail.hours),
                    const SizedBox(height: 12),
                    AmenitiesCard(amenities: detail.amenities),
                    const SizedBox(height: 12),

                    // 타입별 섹션 (이미 구현되어 있다면 사용)
                    // ContentDetailView(detail: detail),
                    const SizedBox(height: 12),
                    ReviewsCard(reviews: detail.reviews),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.calendar_month),
                            label: const Text('방문 계획 추가'),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.group_outlined),
                            label: const Text('친구와 공유'),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
