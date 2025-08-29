/// ChipsRow  [Widget]
/// 역할: dom.Context를 칩 UI로 풀어 표시(P/A/D, 사교, 소음, 혼잡, 위치).
/// 입력: [ctx] dom.Context
/// 사용처: DetailPage 요약, ForYouScreen 요약(유사 UI는 ContextSummary).
/// 주의: 동일/유사 위젯(ContextSummary)과의 책임 분리:
///   - ChipsRow: 텍스트 칩 나열만.
///   - ContextSummary: 카드 배경/패딩/색상 등 '컨테이너' 포함.

// lib/features/foryou/presentation/widgets/chips_row.dart
import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/foryou/domain/entities/context.dart'
    as dom;

class ChipsRow extends StatelessWidget {
  final dom.Context ctx;
  const ChipsRow({super.key, required this.ctx});

  @override
  Widget build(BuildContext context) {
    Chip chip(String label, IconData icon) =>
        Chip(avatar: Icon(icon, size: 16), label: Text(label));
    return Wrap(
      spacing: 8,
      runSpacing: -4,
      children: [
        chip('P:${ctx.P}', Icons.mood),
        chip('A:${ctx.A}', Icons.bolt),
        chip('D:${ctx.D}', Icons.blur_on),
        chip(ctx.sociality == 1 ? '사교' : '혼자', Icons.people_alt),
        chip(ctx.noise == 1 ? '활기' : '조용', Icons.graphic_eq),
        chip(ctx.crowdedness == 1 ? '북적' : '한적', Icons.groups_2),
        chip(ctx.location.toUpperCase(), Icons.place),
      ],
    );
  }
}
