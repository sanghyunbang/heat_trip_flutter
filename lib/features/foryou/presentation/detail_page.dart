// // lib/features/foryou/presentation/detail_page.dart

// /// ─────────────────────────────────────────────────────────────────────────────
// /// CategoryDetailPage  [Screen]
// /// 역할: 추천 카테고리 한 개에 대한 상세 화면 컨테이너.
// ///      입장/이탈 시간을 측정해 바운스/체류 기반 보상 전송을 마무리.
// /// 입력: [category] (카테고리 ID), [contextModel] (도메인 Context)
// /// 출력: 없음. 화면 그리기 + 종료 시 VM.finishDetail 호출.
// /// 의존:
// ///   - State: ForYouVM (markBounced / finishDetail)
// ///   - Widgets: SectionTitle, TitleRow, ChipsRow, ThumbBox, CircleIconButton
// /// UX 흐름:
// ///   - Stopwatch로 상세 체류시간 추적
// ///   - dispose()에서 1.5초 미만이면 바운스로 마킹, finishDetail로 보상 전송
// /// 주의:
// ///   - 화면 간 이동 시 동일 dom.Context를 extra로 전달해야 보상 일관성 유지.
// /// ─────────────────────────────────────────────────────────────────────────────

// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:provider/provider.dart';
// import '../data/dto/context_dto.dart';
// import 'foryou_vm.dart';

// class CategoryDetailPage extends StatefulWidget {
//   final String category;
//   final ContextDto contextDto;
//   const CategoryDetailPage({
//     super.key,
//     required this.category,
//     required this.contextDto,
//   });

//   @override
//   State<CategoryDetailPage> createState() => _CategoryDetailPageState();
// }

// class _CategoryDetailPageState extends State<CategoryDetailPage> {
//   late final Stopwatch _sw;

//   @override
//   void initState() {
//     super.initState();
//     // 상세 체류시간(바운스 판정용)
//     _sw = Stopwatch()..start();
//   }

//   @override
//   void dispose() {
//     _sw.stop();
//     // 1.5초 미만 머물렀다면 bounce 플래그
//     if (_sw.elapsedMilliseconds < 1500) {
//       context.read<ForYouVM>().markBounced(widget.category);
//     }
//     // 상세를 끝냈으니 지연된 피드백을 완료 전송
//     context.read<ForYouVM>().finishDetail(widget.category, widget.contextDto);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 260,
//             pinned: true,
//             stretch: true,
//             title: Text(
//               widget.category,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             flexibleSpace: FlexibleSpaceBar(
//               background: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   // 히어로 이미지(플레이스홀더)
//                   Container(color: cs.primaryContainer),
//                   // 그라데이션 오버레이
//                   DecoratedBox(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.black.withOpacity(0.2),
//                           Colors.transparent,
//                           Colors.black.withOpacity(0.4),
//                         ],
//                         stops: const [0, 0.5, 1],
//                       ),
//                     ),
//                   ),
//                   // 오른쪽 상단 액션
//                   Positioned(
//                     right: 16,
//                     top: MediaQuery.paddingOf(context).top + 12,
//                     child: Row(
//                       children: [
//                         _CircleIconButton(
//                           icon: Icons.share,
//                           onTap: () {
//                             /* 공유 */
//                           },
//                         ),
//                         const SizedBox(width: 8),
//                         _CircleIconButton(
//                           icon: Icons.bookmark_add_outlined,
//                           onTap: () {
//                             /* 저장 */
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // 요약 정보
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _TitleRow(
//                     code: widget.category,
//                     scoreText: 'Score tuned by your mood',
//                   ),
//                   const SizedBox(height: 10),
//                   _ChipsRow(ctx: widget.contextDto),
//                 ],
//               ),
//             ),
//           ),
//           // 소개/설명
//           _SectionTitle('소개'),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 '이 카테고리는 현재 컨텍스트(P:${widget.contextDto.P}, A:${widget.contextDto.A}, '
//                 'D:${widget.contextDto.D})와 잘 맞는 추천이에요. '
//                 '선호(사교:${_yn(widget.contextDto.sociality)}, 소음:${_yn(widget.contextDto.noise)}, '
//                 '혼잡:${_yn(widget.contextDto.crowdedness)}) 및 위치(${widget.contextDto.location.toUpperCase()}) 신호를 반영했습니다.',
//                 style: Theme.of(context).textTheme.bodyMedium,
//               ),
//             ),
//           ),
//           const SliverToBoxAdapter(child: SizedBox(height: 16)),
//           // 갤러리
//           _SectionTitle('갤러리'),
//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: 120,
//               child: ListView.separated(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 scrollDirection: Axis.horizontal,
//                 itemCount: 6,
//                 separatorBuilder: (_, __) => const SizedBox(width: 12),
//                 itemBuilder: (_, i) => _ThumbBox(index: i),
//               ),
//             ),
//           ),
//           const SliverToBoxAdapter(child: SizedBox(height: 16)),
//           // 지도 프리뷰
//           _SectionTitle('지도'),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Stack(
//                   children: [
//                     Container(height: 160, color: cs.surfaceVariant),
//                     Positioned.fill(
//                       child: BackdropFilter(
//                         filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
//                         child: Container(color: Colors.black.withOpacity(0.05)),
//                       ),
//                     ),
//                     Positioned(
//                       right: 12,
//                       bottom: 12,
//                       child: FilledButton.icon(
//                         onPressed: () {
//                           /* 지도 열기 */
//                         },
//                         icon: const Icon(Icons.map),
//                         label: const Text('지도에서 보기'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const SliverToBoxAdapter(child: SizedBox(height: 16)),
//           // 리뷰
//           _SectionTitle('리뷰'),
//           SliverList.separated(
//             itemCount: 3,
//             separatorBuilder: (_, __) =>
//                 const Divider(indent: 16, endIndent: 16),
//             itemBuilder: (_, i) => ListTile(
//               leading: const CircleAvatar(child: Icon(Icons.person)),
//               title: Text('리뷰어 ${i + 1}'),
//               subtitle: const Text('분위기가 좋아요. 다음에 또 오고 싶어요!'),
//               trailing: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   SizedBox(width: 2),
//                   Text('4.7'),
//                 ],
//               ),
//             ),
//           ),
//           const SliverToBoxAdapter(
//             child: SizedBox(height: 88),
//           ), // bottom bar 공간
//         ],
//       ),
//       // 하단 고정 CTA 바
//       bottomNavigationBar: SafeArea(
//         top: false,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
//           child: Row(
//             children: [
//               Expanded(
//                 child: FilledButton.icon(
//                   onPressed: () {
//                     // TODO: 해당 카테고리로 Explore로 이동/필터 적용 등
//                     // context.go('/explore?cat=${widget.category}');
//                   },
//                   icon: const Icon(Icons.explore),
//                   label: const Text('관련 장소 보기'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _yn(int v) => v == 1 ? '예' : '아니오';
// }

// class _SectionTitle extends StatelessWidget {
//   final String text;
//   const _SectionTitle(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return SliverToBoxAdapter(
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
//         child: Text(
//           text,
//           style: Theme.of(
//             context,
//           ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
//         ),
//       ),
//     );
//   }
// }

// class _TitleRow extends StatelessWidget {
//   final String code;
//   final String scoreText;
//   const _TitleRow({required this.code, required this.scoreText});

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     return Row(
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 code,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w800,
//                   fontSize: 20,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 scoreText,
//                 style: TextStyle(
//                   color: Theme.of(context).textTheme.bodySmall?.color,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//           decoration: BoxDecoration(
//             color: cs.secondaryContainer,
//             borderRadius: BorderRadius.circular(999),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.trending_up, color: cs.onSecondaryContainer, size: 16),
//               const SizedBox(width: 6),
//               Text('추천', style: TextStyle(color: cs.onSecondaryContainer)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _ChipsRow extends StatelessWidget {
//   final ContextDto ctx;
//   const _ChipsRow({required this.ctx});

//   @override
//   Widget build(BuildContext context) {
//     Chip chip(String label, IconData icon) =>
//         Chip(avatar: Icon(icon, size: 16), label: Text(label));
//     return Wrap(
//       spacing: 8,
//       runSpacing: -4,
//       children: [
//         chip('P:${ctx.P}', Icons.mood),
//         chip('A:${ctx.A}', Icons.bolt),
//         chip('D:${ctx.D}', Icons.blur_on),
//         chip(ctx.sociality == 1 ? '사교' : '혼자', Icons.people_alt),
//         chip(ctx.noise == 1 ? '활기' : '조용', Icons.graphic_eq),
//         chip(ctx.crowdedness == 1 ? '북적' : '한적', Icons.groups_2),
//         chip(ctx.location.toUpperCase(), Icons.place),
//       ],
//     );
//   }
// }

// class _ThumbBox extends StatelessWidget {
//   final int index;
//   const _ThumbBox({required this.index});
//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         width: 160,
//         height: 120,
//         color: cs.surfaceVariant,
//         child: Center(child: Text('IMG ${index + 1}')),
//       ),
//     ).animate().fadeIn(duration: 250.ms, delay: (index * 40).ms);
//   }
// }

// class _CircleIconButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _CircleIconButton({required this.icon, required this.onTap});
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.black.withOpacity(0.28),
//       shape: const CircleBorder(),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Icon(icon, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }
