// lib/features/foryou/presentation/screens/foryou_screen.dart

/// ─────────────────────────────────────────────────────────────────────────────
/// ForYouScreen  [Screen]
/// 역할: "For You" 추천 리스트 화면의 컨테이너. 데이터 로딩/리프레시 트리거,
///      리스트 렌더링, 라우팅(상세 진입)을 담당.
/// 입력: [contextModel] (도메인 Context), [k] (Top-K)
/// 출력: 없음. 화면 그리기 + 사용자 액션을 VM으로 전달.
/// 의존:
///   - State: ForYouVM (load / onCardVisible / onCardInvisible / onTap)
///   - Widgets: KPicker, ContextSummary, CategoryCard, SkeletonCard, ErrorView
/// 데이터 흐름:
///   1) initState에서 VM.load(contextModel, k) 호출 → 비동기 로딩
///   2) VM.items/VM.loading/VM.error에 따라 3가지 UI 상태 처리
///   3) CategoryCard의 가시성/탭 이벤트를 VM에 위임
/// 네이밍 팁:
///   - Screen은 페이지 컨테이너. 세부 UI는 widgets/로 분리.
/// 주의:
///   - DTO 대신 도메인 모델(dom.Context, dom.RankItem)만 사용.
///   - 라우팅 시 extra로 dom.Context 전달.
/// ────
///
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:heat_trip_flutter/features/foryou/domain/entities/context.dart'
    as dom;
import '../states/foryou_vm.dart';

// widgets
import '../widgets/k_picker.dart';
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
            SliverAppBar(
              floating: true,
              snap: true,
              title: const Text(
                'For You',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              actions: [
                KPicker(
                  value: vm.k,
                  onChanged: (v) =>
                      context.read<ForYouVM>().load(widget.contextModel, k: v),
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(child: ContextSummary(ctx: widget.contextModel)),
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
              SliverList.builder(
                itemCount: vm.items.length,
                itemBuilder: (_, i) {
                  final item = vm.items[i];
                  return CategoryCard(
                        item: item,
                        onVisible: () => vm.onCardVisible(item.category),
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
                      .slideY(begin: .08, end: 0, duration: 240.ms)
                      .fadeIn(duration: 240.ms);
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
