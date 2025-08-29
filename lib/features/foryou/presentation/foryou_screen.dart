// // lib/features/foryou/presentation/foryou_screen.dart

// /// ─────────────────────────────────────────────────────────────────────────────
// /// ForYouScreen  [Screen]
// /// 역할: "For You" 추천 리스트 화면의 컨테이너. 데이터 로딩/리프레시 트리거,
// ///      리스트 렌더링, 라우팅(상세 진입)을 담당.
// /// 입력: [contextModel] (도메인 Context), [k] (Top-K)
// /// 출력: 없음. 화면 그리기 + 사용자 액션을 VM으로 전달.
// /// 의존:
// ///   - State: ForYouVM (load / onCardVisible / onCardInvisible / onTap)
// ///   - Widgets: KPicker, ContextSummary, CategoryCard, SkeletonCard, ErrorView
// /// 데이터 흐름:
// ///   1) initState에서 VM.load(contextModel, k) 호출 → 비동기 로딩
// ///   2) VM.items/VM.loading/VM.error에 따라 3가지 UI 상태 처리
// ///   3) CategoryCard의 가시성/탭 이벤트를 VM에 위임
// /// 네이밍 팁:
// ///   - Screen은 페이지 컨테이너. 세부 UI는 widgets/로 분리.
// /// 주의:
// ///   - DTO 대신 도메인 모델(dom.Context, dom.RankItem)만 사용.
// ///   - 라우팅 시 extra로 dom.Context 전달.
// /// ─────────────────────────────────────────────────────────────────────────────

// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:visibility_detector/visibility_detector.dart';

// import '../data/dto/context_dto.dart';
// import '../data/dto/rank_item_dto.dart';
// import 'foryou_vm.dart';

// class ForYouScreen extends StatefulWidget {
//   final ContextDto contextDto;
//   final int k;
//   const ForYouScreen({super.key, required this.contextDto, this.k = 8});

//   @override
//   State<ForYouScreen> createState() => _ForYouScreenState();
// }

// class _ForYouScreenState extends State<ForYouScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(
//       () => context.read<ForYouVM>().load(widget.contextDto, k: widget.k),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final vm = context.watch<ForYouVM>();
//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: () => context.read<ForYouVM>().load(widget.contextDto),
//         child: CustomScrollView(
//           slivers: [
//             SliverAppBar(
//               floating: true,
//               snap: true,
//               title: const Text(
//                 'For You',
//                 style: TextStyle(fontWeight: FontWeight.w700),
//               ),
//               actions: [
//                 _KPicker(
//                   value: vm.k,
//                   onChanged: (v) =>
//                       context.read<ForYouVM>().load(widget.contextDto, k: v),
//                 ),
//                 const SizedBox(width: 8),
//               ],
//             ),
//             SliverToBoxAdapter(child: _ContextSummary(ctx: widget.contextDto)),
//             if (vm.loading)
//               SliverList.builder(
//                 itemCount: 6,
//                 itemBuilder: (_, __) =>
//                     const _SkeletonCard().animate().fadeIn(duration: 300.ms),
//               )
//             else if (vm.error != null)
//               SliverFillRemaining(
//                 hasScrollBody: false,
//                 child: _ErrorView(
//                   message: vm.error.toString(),
//                   onRetry: () =>
//                       context.read<ForYouVM>().load(widget.contextDto),
//                 ).animate().fadeIn(duration: 250.ms),
//               )
//             else
//               SliverList.builder(
//                 itemCount: vm.items.length,
//                 itemBuilder: (_, i) {
//                   final item = vm.items[i];
//                   return _CategoryCard(
//                         item: item,
//                         onVisible: () => vm.onCardVisible(item.category),
//                         onInvisible: () => vm.onCardInvisible(
//                           item.category,
//                           widget.contextDto,
//                         ),
//                         onTap: () {
//                           vm.onTap(item.category);
//                           context.push(
//                             '/foryou/detail/${item.category}',
//                             extra: widget.contextDto,
//                           );
//                         },
//                       )
//                       .animate()
//                       .slideY(begin: .08, end: 0, duration: 240.ms)
//                       .fadeIn(duration: 240.ms);
//                 },
//               ),
//             const SliverToBoxAdapter(child: SizedBox(height: 24)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _KPicker extends StatelessWidget {
//   final int value;
//   final ValueChanged<int> onChanged;
//   const _KPicker({required this.value, required this.onChanged});
//   @override
//   Widget build(BuildContext context) {
//     final options = const [4, 8, 12];
//     return SegmentedButton<int>(
//       segments: options
//           .map((e) => ButtonSegment(value: e, label: Text('K=$e')))
//           .toList(),
//       selected: {value},
//       showSelectedIcon: false,
//       onSelectionChanged: (s) => onChanged(s.first),
//     );
//   }
// }

// class _ContextSummary extends StatelessWidget {
//   final ContextDto ctx;
//   const _ContextSummary({required this.ctx});
//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     Chip chip(String label, IconData icon) =>
//         Chip(avatar: Icon(icon, size: 18), label: Text(label));
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//       child: Material(
//         color: cs.primaryContainer,
//         elevation: 1,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Wrap(
//             spacing: 8,
//             runSpacing: -4,
//             children: [
//               chip('P:${ctx.P}', Icons.mood),
//               chip('A:${ctx.A}', Icons.bolt),
//               chip('D:${ctx.D}', Icons.blur_on),
//               chip(ctx.sociality == 1 ? '사교적' : '혼자', Icons.people_alt),
//               chip(ctx.noise == 1 ? '활기' : '조용', Icons.graphic_eq),
//               chip(ctx.crowdedness == 1 ? '북적' : '한적', Icons.groups_2),
//               chip(ctx.location.toUpperCase(), Icons.place),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _CategoryCard extends StatelessWidget {
//   final RankItemDto item;
//   final VoidCallback onVisible, onInvisible, onTap;
//   const _CategoryCard({
//     required this.item,
//     required this.onVisible,
//     required this.onInvisible,
//     required this.onTap,
//   });
//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//       child: VisibilityDetector(
//         key: Key('cat-${item.category}'),
//         onVisibilityChanged: (info) {
//           if (info.visibleFraction > 0.6) onVisible();
//           if (info.visibleFraction == 0.0) onInvisible();
//         },
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(18),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(18),
//               gradient: LinearGradient(
//                 colors: [cs.primaryContainer, cs.surfaceVariant],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: cs.primary.withOpacity(.12),
//                   blurRadius: 16,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Container(
//                   width: 56,
//                   height: 56,
//                   decoration: BoxDecoration(
//                     color: cs.onSecondaryContainer.withOpacity(.08),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: const Icon(Icons.map, size: 28),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         item.category,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 16,
//                           height: 1.1,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         '추천 점수 기반 카테고리',
//                         style: TextStyle(
//                           color: Theme.of(context).textTheme.bodySmall?.color,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 _ScorePill(score: item.score),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ScorePill extends StatelessWidget {
//   final double score;
//   const _ScorePill({required this.score});
//   @override
//   Widget build(BuildContext context) {
//     final bg = Theme.of(context).colorScheme.secondaryContainer;
//     final fg = Theme.of(context).colorScheme.onSecondaryContainer;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(999),
//       ),
//       child: Text(
//         score.toStringAsFixed(3),
//         style: TextStyle(
//           color: fg,
//           fontFeatures: const [FontFeature.tabularFigures()],
//         ),
//       ),
//     );
//   }
// }

// class _SkeletonCard extends StatelessWidget {
//   const _SkeletonCard();
//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//       child: Container(
//         height: 84,
//         decoration: BoxDecoration(
//           color: cs.surfaceVariant.withOpacity(.6),
//           borderRadius: BorderRadius.circular(18),
//         ),
//       ),
//     );
//   }
// }

// class _ErrorView extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry;
//   const _ErrorView({required this.message, required this.onRetry});
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.wifi_off, size: 48),
//             const SizedBox(height: 12),
//             Text('네트워크 오류', style: Theme.of(context).textTheme.titleLarge),
//             const SizedBox(height: 8),
//             Text(message, textAlign: TextAlign.center),
//             const SizedBox(height: 12),
//             FilledButton.icon(
//               onPressed: onRetry,
//               icon: const Icon(Icons.refresh),
//               label: const Text('다시 시도'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
