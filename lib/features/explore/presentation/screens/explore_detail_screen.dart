/// explore_detail_screen.dart
/// ─────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/core/net/logging_client.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../domain/entity_detail/place_detail.dart';
import '../state/detail_vm.dart';

// ✅ FallbackAppBar + SliverDetailAppBar 둘 다 사용
import '../widgets_detail/detail_appbars.dart';

import '../widgets_detail/header_info.dart';
import '../widgets_detail/gallery.dart';
import '../widgets_detail/contact_card.dart';
import '../widgets_detail/hours_card.dart';
import '../widgets_detail/amenities_card.dart';
import '../widgets_detail/reviews_card.dart';
import '../widgets_detail/strip_html.dart';

// 감정 탭 묶음: API/Repo/VM + 세부 탭 3종
import '../../data_detail/emotion_api.dart';
import '../../data_detail/emotion_repository.dart';
import '../state/detail_emotion_vm.dart';
import '../widgets_detail/emotion/emotion_tab.dart' as emo;
import '../widgets_detail/emotion/features_tab.dart' as emo_features;
import '../widgets_detail/emotion/feedback_tab.dart' as emo_feedback;

import 'package:heat_trip_flutter/core/config/env.dart';

class ExploreDetailScreen extends StatefulWidget {
  final int contentId; // 상세 API 키
  final int contentTypeId; // 타입(관광지, 숙박 등)

  /// ✅ 목록 카드에서 전달받은 시드 이미지 (외부 API 실패 시 갤러리 fallback)
  final String? seedImage;

  const ExploreDetailScreen({
    super.key,
    required this.contentId,
    required this.contentTypeId,
    this.seedImage, // ✅ 추가
  });

  @override
  State<ExploreDetailScreen> createState() => _ExploreDetailScreenState();
}

class _ExploreDetailScreenState extends State<ExploreDetailScreen> {
  static const Color kPrimary = Color(0xFFEB9C64);

  int _galleryIndex = 0; // 갤러리 페이지 인덱스

  @override
  void initState() {
    super.initState();
    debugPrint(
      '[ExploreDetail] initState: contentId=${widget.contentId}, typeId=${widget.contentTypeId}',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('[ExploreDetail] calling DetailVM.load()');
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
      // 라우트 스택을 갈아엎는 go 금지
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailVM>();
    debugPrint(
      '[ExploreDetail] build: loading=${vm.loading}, error=${vm.error}, hasData=${vm.data != null}',
    );

    // 공통 스타일
    final divider = const Divider(
      height: 1,
      thickness: .6,
      color: Color(0xFFE9E9E9),
    );
    final sectionTitleStyle = const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 16,
    );

    // 1) 로딩
    if (vm.loading) {
      return Scaffold(
        appBar: FallbackAppBar(titleText: '로딩 중…', onBack: _safePop),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 2) 에러 (레포가 부분 실패 허용이면 거의 안 옴)
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
                  style: FilledButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
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

    // ✅ 대표 이미지 + 추가 이미지 + seedImage 병합 (중복 제거)
    final mergedImages = <String>{
      if ((detail.firstImage ?? '').isNotEmpty) detail.firstImage!,
      if ((widget.seedImage ?? '').isNotEmpty) widget.seedImage!, // ← 목록 썸네일 보강
      ...detail.images, // mappers에서 합쳐온 리스트(있다면)
    }.toList();

    // 완전 빈 경우라도 seedImage 1장 사용 (상단이 텅 비지 않게)
    final galleryImages = mergedImages.isNotEmpty
        ? mergedImages
        : ((widget.seedImage ?? '').isNotEmpty
              ? [widget.seedImage!]
              : const <String>[]);

    // 4) 성공 UI: SliverAppBar(갤러리) + 본문(탭 UI)
    return Theme(
      // 화면 단위로 포인트 컬러를 통일
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(
          context,
        ).colorScheme.copyWith(primary: kPrimary, secondary: kPrimary),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kPrimary,
            side: const BorderSide(color: kPrimary, width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kPrimary,
            overlayColor: kPrimary.withOpacity(.08),
          ),
        ),
      ),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // ✅ SliverDetailAppBar 사용
            SliverDetailAppBar(
              title: '', // 사진 위 텍스트는 숨김
              contentId: widget.contentId.toString(),
              onBack: _safePop,
              gallery: Gallery(
                images: galleryImages, // ✅ 보정된 리스트 사용
                index: _galleryIndex,
                onChanged: (i) => setState(() => _galleryIndex = i),
              ),
            ),

            // 본문: 탭 UI (개요/감정경험/공간특성/나의경험)
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: ChangeNotifierProvider(
                    create: (_) {
                      final host = (Env.apiBase ?? 'http://localhost:8080')
                          .replaceFirst(RegExp(r'/*$'), ''); // 말단 슬래시 제거
                      final api = EmotionApi(
                        LoggingClient(http.Client()),
                        apiBaseFromEnv: host,
                      );
                      final repo = EmotionRepository(api);
                      final evm = DetailEmotionVM(
                        repo: repo,
                        contentId: widget.contentId,
                      );
                      evm.init(); // 특성/리뷰 병렬 로드
                      evm.setTab(EmotionTab.overview); // 진입 시 "개요" 탭
                      return evm;
                    },
                    child: _DetailTabs(
                      detail: detail,
                      sectionTitleStyle: sectionTitleStyle,
                      divider: divider,
                      primary: kPrimary,
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

/// 탭 렌더링: 상단 탭 버튼 + 본문 스위치
class _DetailTabs extends StatelessWidget {
  final PlaceDetail detail;
  final TextStyle sectionTitleStyle;
  final Divider divider;
  final Color primary;

  const _DetailTabs({
    required this.detail,
    required this.sectionTitleStyle,
    required this.divider,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final evm = context.watch<DetailEmotionVM>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 탭 버튼 행 ─────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDEDED)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: [
              _TabButton(
                label: '개요',
                tab: EmotionTab.overview,
                evm: evm,
                primary: primary,
              ),
              _TabButton(
                label: '공간 특성',
                tab: EmotionTab.features,
                evm: evm,
                primary: primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── 탭 본문 ───────────────────────────────────────────────────
        Builder(
          builder: (_) {
            switch (evm.active) {
              case EmotionTab.overview:
                return _OverviewTab(
                  detail: detail,
                  sectionTitleStyle: sectionTitleStyle,
                  divider: divider,
                  primary: primary,
                );
              case EmotionTab.emotion:
                return const emo.EmotionTab();
              case EmotionTab.features:
                return const emo_features.FeaturesTab();
              case EmotionTab.feedback:
                return const emo_feedback.FeedbackTab();
            }
          },
        ),
      ],
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final PlaceDetail detail;
  final TextStyle sectionTitleStyle;
  final Divider divider;
  final Color primary;

  const _OverviewTab({
    required this.detail,
    required this.sectionTitleStyle,
    required this.divider,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderInfo(detail: detail),
        const SizedBox(height: 12),

        if ((detail.overview ?? '').isNotEmpty) ...[
          divider,
          const SizedBox(height: 14),
          Text('개요', style: sectionTitleStyle),
          const SizedBox(height: 8),
          Text(
            stripHtml(detail.overview!),
            style: const TextStyle(height: 1.45),
          ),
        ],

        const SizedBox(height: 18),
        ContactCard(detail: detail),
        const SizedBox(height: 12),
        HoursCard(hours: detail.hours),
        const SizedBox(height: 12),
        AmenitiesCard(amenities: detail.amenities),
        const SizedBox(height: 12),
        ReviewsCard(reviews: detail.reviews),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final EmotionTab tab;
  final DetailEmotionVM evm;
  final Color primary;

  const _TabButton({
    required this.label,
    required this.tab,
    required this.evm,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final on = evm.active == tab;

    return Expanded(
      child: TextButton(
        onPressed: () => evm.setTab(tab),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: on ? primary : Colors.black87,
                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 2.4,
              width: on ? 28 : 0,
              decoration: BoxDecoration(
                color: on ? primary : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
