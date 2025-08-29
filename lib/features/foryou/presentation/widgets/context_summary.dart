// lib/features/foryou/presentation/widgets/context_summary.dart

/// ContextSummary  [Widget]
/// 역할: 현재 추천 컨텍스트(PAD, 사교/소음/혼잡, 위치)를 칩 형태로 요약 표시.
/// 입력: [ctx] dom.Context
/// 사용처: ForYouScreen 상단 요약 박스.
/// 주의: 값 범위(PAD: -2/-1/1/2, 선호: -1/1)가 UI 문구에 반영됨.

import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/foryou/domain/entities/context.dart'
    as dom;

class ContextSummary extends StatelessWidget {
  final dom.Context ctx;
  const ContextSummary({super.key, required this.ctx});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Chip chip(String label, IconData icon) =>
        Chip(avatar: Icon(icon, size: 18), label: Text(label));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Material(
        color: cs.primaryContainer,
        elevation: 1,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: -4,
            children: [
              chip('P:${ctx.P}', Icons.mood),
              chip('A:${ctx.A}', Icons.bolt),
              chip('D:${ctx.D}', Icons.blur_on),
              chip(ctx.sociality == 1 ? '사교적' : '혼자', Icons.people_alt),
              chip(ctx.noise == 1 ? '활기' : '조용', Icons.graphic_eq),
              chip(ctx.crowdedness == 1 ? '북적' : '한적', Icons.groups_2),
              chip(ctx.location.toUpperCase(), Icons.place),
            ],
          ),
        ),
      ),
    );
  }
}
