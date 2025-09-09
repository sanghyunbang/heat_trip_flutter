/// explore_detail_screen.dart
/// ─────────────────────────────────────────────────────────────────────────
/// 역할
/// - DetailVM(기존) 상태 구독: 로딩/에러/성공 처리
/// - 성공 시: SliverAppBar(갤러리) + 본문에 "탭 UI" 구성
/// - 탭: ① 개요(Overview) ② 감정 경험 ③ 공간 특성 ④ 나의 경험
/// - 감정 관련 데이터 로드/제출은 DetailEmotionVM(별도)으로 분리
/// - 북마크/공유/뒤로가기 UX 유지 + 사진 위/앱바 제목 텍스트 제거
/// ─────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../domain/entity_detail/place_detail.dart';
import '../state/detail_vm.dart';

// 기존 섹션 위젯들(개요 탭에서 재사용)
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

// 감정 탭 묶음: API/Repo/VM + 세부 탭 3종
import '../../data_detail/emotion_api.dart';
import '../../data_detail/emotion_repository.dart';
import '../state/detail_emotion_vm.dart';
import '../widgets_detail/emotion/emotion_tab.dart' as emo;
import '../widgets_detail/emotion/features_tab.dart' as emo_features;
import '../widgets_detail/emotion/feedback_tab.dart' as emo_feedback;

import 'package:flutter_dotenv/flutter_dotenv.dart'; // ⬅ 추가

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
  int _galleryIndex = 0; // 갤러리 페이지 인덱스

  @override
  void initState() {
    super.initState();
    // 스토어 초기화 + 상세 데이터 로드(기존 DetailVM)
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

    // 4) 성공 UI: SliverAppBar(갤러리) + 본문(탭 UI)
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─────────────────────────────────────────────────────────────
          // 상단 SliverAppBar: 뒤로가기/공유/북마크 + 사진 갤러리
          // ─────────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 300,
            title: null, // 앱바 텍스트 완전 제거
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
            flexibleSpace: FlexibleSpaceBar(
              title: null, // 사진 위 오버레이 제목 제거
              collapseMode: CollapseMode.parallax,
              background: Gallery(
                images: images,
                index: _galleryIndex,
                onChanged: (i) => setState(() => _galleryIndex = i),
              ),
            ),
          ),

          // ─────────────────────────────────────────────────────────────
          // 본문: 탭 UI (개요/감정경험/공간특성/나의경험)
          // ─────────────────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              Padding(
                padding: const EdgeInsets.all(16),
                // 감정 탭 묶음은 별도 VM로 관리(네트워크 로드/제출 포함)
                child: ChangeNotifierProvider(
                  create: (_) {
                    // 1) .env에서 API_BASE_URL 읽기 (예: http://222.111.78.27:8080)
                    //    값이 없으면 로컬로 폴백(개발편의)
                    final host = (dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080')
                        .replaceFirst(RegExp(r'/*$'), ''); // 말단 슬래시 제거

                    // 2) EmotionApi는 내부에서 "/api/explore/places"를 자동 덧붙임
                    final api  = EmotionApi(
                      http.Client(),
                      apiBaseFromEnv: host,
                    );

                    final repo = EmotionRepository(api);
                    final evm  = DetailEmotionVM(repo: repo, contentId: widget.contentId);
                    evm.init(); // 특성/리뷰 병렬 로드
                    evm.setTab(EmotionTab.overview); // 진입 시 "개요" 탭
                    return evm;
 
                  },
                  child: _DetailTabs(detail: detail),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

/// 탭 렌더링: 상단 탭 버튼 + 본문 스위치
class _DetailTabs extends StatelessWidget {
  final PlaceDetail detail;
  const _DetailTabs({required this.detail});

  @override
  Widget build(BuildContext context) {
    final evm = context.watch<DetailEmotionVM>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 탭 버튼 행 ─────────────────────────────────────────────────
        Row(
          children: [
            _TabButton(label: '개요', tab: EmotionTab.overview, evm: evm),
            _TabButton(label: '감정 경험', tab: EmotionTab.emotion, evm: evm),
            _TabButton(label: '공간 특성', tab: EmotionTab.features, evm: evm),
            _TabButton(label: '나의 경험', tab: EmotionTab.feedback, evm: evm),
          ],
        ),
        const SizedBox(height: 12),

        // ── 탭 본문 ───────────────────────────────────────────────────
        Builder(
          builder: (_) {
            switch (evm.active) {
              case EmotionTab.overview:
                return _OverviewTab(detail: detail); // (기존 섹션들 통합)
              case EmotionTab.emotion:
                return const emo.EmotionTab(); // 감정 리뷰/변화도
              case EmotionTab.features:
                return const emo_features.FeaturesTab(); // DB 특성 표시
              case EmotionTab.feedback:
                return const emo_feedback.FeedbackTab(); // 사용자 입력/제출
            }
          },
        ),
      ],
    );
  }
}

/// 개요(Overview) 탭: 기존의 상세 섹션들을 그대로 조립
class _OverviewTab extends StatelessWidget {
  final PlaceDetail detail;
  const _OverviewTab({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Column(
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
        ReviewsCard(reviews: detail.reviews), // ← 일반 리뷰(감정 리뷰와 별개)

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
      ],
    );
  }
}

/// 탭 버튼 공통 위젯(선택 시 하단 라인/색상 강조)
class _TabButton extends StatelessWidget {
  final String label;
  final EmotionTab tab;
  final DetailEmotionVM evm;

  const _TabButton({
    required this.label,
    required this.tab,
    required this.evm,
  });

  @override
  Widget build(BuildContext context) {
    final on = evm.active == tab;
    final color = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: TextButton(
        onPressed: () => evm.setTab(tab),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: on ? color : null,
                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
            )),
            const SizedBox(height: 6),
            Container(
              height: 2,
              color: on ? color : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
