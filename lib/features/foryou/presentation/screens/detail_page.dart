// lib/features/foryou/presentation/screens/detail_page.dart

/// ─────────────────────────────────────────────────────────────────────────────
/// CategoryDetailPage  [Screen]
/// 역할: 추천 카테고리 한 개에 대한 상세 화면 컨테이너.
///      입장/이탈 시간을 측정해 바운스/체류 기반 보상 전송을 마무리.
/// 입력: [category] (카테고리 ID), [contextModel] (도메인 Context)
/// 출력: 없음. 화면 그리기 + 종료 시 VM.finishDetail 호출.
/// 의존:
///   - State: ForYouVM (markBounced / finishDetail)
///   - Widgets: SectionTitle, TitleRow, ChipsRow, ThumbBox, CircleIconButton
/// UX 흐름:
///   - Stopwatch로 상세 체류시간 추적
///   - dispose()에서 1.5초 미만이면 바운스로 마킹, finishDetail로 보상 전송
/// 주의:
///   - 화면 간 이동 시 동일 dom.Context를 extra로 전달해야 보상 일관성 유지.
///
///
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:heat_trip_flutter/features/foryou/domain/entities/context.dart'
    as dom;
import '../states/foryou_vm.dart';

// widgets
import '../widgets/section_title.dart';
import '../widgets/chips_row.dart';
import '../widgets/thumb_box.dart';
import '../widgets/circle_icon_button.dart';
import '../widgets/title_row.dart';

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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            title: Text(
              widget.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: cs.primaryContainer),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                        stops: const [0, 0.5, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: MediaQuery.paddingOf(context).top + 12,
                    child: Row(
                      children: [
                        CircleIconButton(icon: Icons.share, onTap: () {}),
                        const SizedBox(width: 8),
                        CircleIconButton(
                          icon: Icons.bookmark_add_outlined,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 요약
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleRow(
                    code: widget.category,
                    scoreText: 'Score tuned by your mood',
                  ),
                  const SizedBox(height: 10),
                  ChipsRow(ctx: widget.contextModel),
                ],
              ),
            ),
          ),
          SectionTitle('소개'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '이 카테고리는 현재 컨텍스트(P:${widget.contextModel.P}, '
                'A:${widget.contextModel.A}, D:${widget.contextModel.D})와 잘 맞는 추천이에요. '
                '선호(사교:${_yn(widget.contextModel.sociality)}, '
                '소음:${_yn(widget.contextModel.noise)}, '
                '혼잡:${_yn(widget.contextModel.crowdedness)}) 및 '
                '위치(${widget.contextModel.location.toUpperCase()}) 신호를 반영했습니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SectionTitle('갤러리'),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => ThumbBox(index: i),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SectionTitle('지도'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Container(height: 160, color: cs.surfaceVariant),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                        child: Container(color: Colors.black.withOpacity(0.05)),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.map),
                        label: const Text('지도에서 보기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SectionTitle('리뷰'),
          SliverList.separated(
            itemCount: 3,
            separatorBuilder: (_, __) =>
                const Divider(indent: 16, endIndent: 16),
            itemBuilder: (_, i) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text('리뷰어 ${i + 1}'),
              subtitle: const Text('분위기가 좋아요. 다음에 또 오고 싶어요!'),
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 18),
                  SizedBox(width: 2),
                  Text('4.7'),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.explore),
                  label: const Text('관련 장소 보기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _yn(int v) => v == 1 ? '예' : '아니오';
}
