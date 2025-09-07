/// explore_detail_screen.dart
/// ─────────────────────────────────────────────────────────────────────────
/// 역할
/// - DetailVM 상태 구독 (로딩/에러/성공)
/// - 로딩/에러에서도 항상 '뒤로가기'를 보장 (FallbackAppBar)
/// - 성공 시: SliverAppBar + 섹션 위젯들 조립
/// - 네비게이션 안전 팝(safePop) 제공 (go_router/일반 Navigator 모두 대응)
/// - ✅ 사진 위/앱바에 제목 텍스트 완전 제거 (오버레이 텍스트 없음)
/// ─────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entity_detail/place_detail.dart';
import '../state/detail_vm.dart';

// 섹션 위젯들
import '../widgets_detail/detail_appbars.dart' show FallbackAppBar; // FallbackAppBar만 사용
import '../widgets_detail/header_info.dart';
import '../widgets_detail/gallery.dart';
import '../widgets_detail/contact_card.dart';
import '../widgets_detail/hours_card.dart';
import '../widgets_detail/amenities_card.dart';
import '../widgets_detail/reviews_card.dart';
import '../widgets_detail/strip_html.dart';

// 북마크 관련
import 'package:heat_trip_flutter/features/bookmark/service/bookmark_store.dart';
import 'package:heat_trip_flutter/features/bookmark/presentation/collection_picker_sheet.dart';

class ExploreDetailScreen extends StatefulWidget {
  final int contentId;     // 상세 API 키
  final int contentTypeId; // 타입(관광지, 숙박 등)

  const ExploreDetailScreen({
    super.key,
    required this.contentId,
    required this.contentTypeId,
  });

  @override
  State<ExploreDetailScreen> createState() => _ExploreDetailScreenState();
}

class _ExploreDetailScreenState extends State<ExploreDetailScreen> {
  int _galleryIndex = 0;

  @override
  void initState() {
    super.initState();
    // 스토어 초기화 + VM 로드 보장
    Future.microtask(() async {
      await BookmarkStore.instance.ensureInitialized();
      await context.read<DetailVM>().load(
        contentId: widget.contentId,
        contentTypeId: widget.contentTypeId,
      );
    });
  }

  /// go_router 또는 일반 Navigator를 모두 고려한 안전한 뒤로가기
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
    final vm = context.watch<DetailVM>();

    // 1) 로딩
    if (vm.loading) {
      return Scaffold(
        appBar: FallbackAppBar(titleText: '로딩 중…', onBack: _safePop),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 2) 에러
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
                  onPressed: () async {
                    await context.read<DetailVM>().load(
                      contentId: widget.contentId,
                      contentTypeId: widget.contentTypeId,
                    );
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3) 성공 데이터
    final PlaceDetail? detail = vm.data;
    if (detail == null) {
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

    // 4) 성공 UI: 확장 SliverAppBar + 섹션 (제목 텍스트 완전 제거)
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 300,
            // 앱바 영역에 제목을 넣지 않음
            title: null,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _safePop,
              tooltip: '뒤로가기',
            ),
            actions: [
              // 공유
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('공유 기능은 이후 연결하세요.')),
                  );
                },
                tooltip: '공유',
              ),
              // 북마크 (전역 스토어 구독)
              AnimatedBuilder(
                animation: BookmarkStore.instance,
                builder: (context, _) {
                  final idStr = widget.contentId.toString();
                  final isOn = BookmarkStore.instance.isBookmarked(idStr);
                  return IconButton(
                    icon: Icon(isOn ? Icons.favorite : Icons.favorite_border),
                    color: isOn ? Colors.red : null,
                    tooltip: '북마크',
                    onPressed: () async {
                      try {
                        await BookmarkStore.instance.ensureInitialized();
                        final isOnNow = BookmarkStore.instance.isBookmarked(idStr);

                        final res = await showCollectionPickerSheet(
                          context,
                          alreadyBookmarked: isOnNow,
                        );
                        if (res == null) return; // 취소

                        if (res.removed) {
                          if (isOnNow) {
                            await BookmarkStore.instance.toggle(idStr);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('북마크에서 제거했어요')),
                            );
                            setState(() {}); // 필요시 리빌드
                          }
                          return;
                        }

                        if (!isOnNow) {
                          // 저장
                          await BookmarkStore.instance.toggle(
                            idStr,
                            collectionId: res.collectionId?.toString(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                res.collectionId == null
                                    ? '북마크에 저장했어요'
                                    : '선택한 컬렉션에 저장했어요',
                              ),
                            ),
                          );
                        } else {
                          // 이미 저장 상태에서 컬렉션 지정 → remove → add(컬렉션)
                          if (res.collectionId != null) {
                            await BookmarkStore.instance.toggle(idStr); // remove
                            await BookmarkStore.instance.toggle(
                              idStr,
                              collectionId: res.collectionId!.toString(),
                            ); // add + attach
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('선택한 컬렉션에 저장했어요')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('이미 북마크에 있어요')),
                            );
                          }
                        }

                        setState(() {}); // 필요시 리빌드
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('처리 중 오류가 발생했어요: $e')),
                        );
                      }
                    },
                  );
                },
              ),
            ],
            // 사진 위 오버레이 제목도 넣지 않음
            flexibleSpace: FlexibleSpaceBar(
              title: null,
              collapseMode: CollapseMode.parallax,
              background: Gallery(
                images: images,
                index: _galleryIndex,
                onChanged: (i) => setState(() => _galleryIndex = i),
              ),
            ),
          ),

          // 본문 섹션
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeaderInfo(detail: detail),
                    const SizedBox(height: 12),

                    if ((detail.overview ?? '').isNotEmpty) ...[
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text('개요', style: TextStyle(fontWeight: FontWeight.w700)),
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
