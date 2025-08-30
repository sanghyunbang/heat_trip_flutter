// lib/features/foryou/presentation/screens/foryou_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:heat_trip_flutter/features/foryou/domain/entities/context.dart'
    as dom;
import '../states/foryou_vm.dart';

// 위젯들
import '../widgets/k_picker.dart'; // ⬅ KPicker(framed: false) 사용
import '../widgets/context_summary.dart';
import '../widgets/category_card.dart';
import '../widgets/skeleton_card.dart';
import '../widgets/error_view.dart';

class ForYouScreen extends StatefulWidget {
  final dom.Context contextModel;
  final int k;
  const ForYouScreen({super.key, required this.contextModel, this.k = 8});

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  @override
  void initState() {
    super.initState();
    // 초기 로딩은 다음 이벤트 루프로 미뤄 안전하게 트리거
    Future.microtask(
      () => context.read<ForYouVM>().load(widget.contextModel, k: widget.k),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForYouVM>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<ForYouVM>().load(widget.contextModel),
        child: CustomScrollView(
          slivers: [
            // ───────────────── AppBar ─────────────────
            // actions에 KPicker 두지 않음(요청: Summary 아래/오른쪽 정렬)
            SliverAppBar(
              floating: true,
              snap: true,
              title: const Text(
                'For You',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),

            // ───────────── Summary(칩 그라디언트 박스) ─────────────
            SliverToBoxAdapter(child: ContextSummary(ctx: widget.contextModel)),

            // ───────────── Summary 아래 · 추천 카테고리 위 ─────────────
            // KPicker 오른쪽 정렬 + 외곽 큰 오벌 제거(framed: false)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: KPicker(
                    value: vm.k,
                    framed: false, // ⬅ 외곽 캡슐(오벌) 제거
                    onChanged: (v) => context.read<ForYouVM>().load(
                      widget.contextModel,
                      k: v,
                    ),
                  ),
                ),
              ),
            ),

            // ───────────── 데이터 렌더링(로딩/에러/정상) ─────────────
            if (vm.loading)
              SliverList.builder(
                itemCount: 6,
                itemBuilder: (_, __) =>
                    const SkeletonCard().animate().fadeIn(duration: 300.ms),
              )
            else if (vm.error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorView(
                  message: vm.error.toString(),
                  onRetry: () =>
                      context.read<ForYouVM>().load(widget.contextModel),
                ).animate().fadeIn(duration: 250.ms),
              )
            else
              // 추천 카테고리 카드 컨테이너
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFEBE2CD).withOpacity(.8),
                        width: .8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 섹션 헤더
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
                          child: Text(
                            '추천 카테고리',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFF353535),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0x15000000)),
                        // 리스트
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: vm.items.length,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: Color(0x14000000),
                          ),
                          itemBuilder: (_, i) {
                            final item = vm.items[i];
                            return CategoryCard(
                                  item: item,
                                  onVisible: () =>
                                      vm.onCardVisible(item.category),
                                  onInvisible: () => vm.onCardInvisible(
                                    item.category,
                                    widget.contextModel,
                                  ),
                                  onTap: () {
                                    vm.onTap(item.category);
                                    context.push(
                                      '/foryou/detail/${item.category}',
                                      extra: widget.contextModel,
                                    );
                                  },
                                )
                                .animate()
                                .slideY(begin: .06, end: 0, duration: 200.ms)
                                .fadeIn(duration: 200.ms);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
