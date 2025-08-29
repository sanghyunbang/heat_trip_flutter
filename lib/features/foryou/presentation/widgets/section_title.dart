/// SectionTitle  [Widget]
/// 역할: 슬리버 레이아웃 내 섹션 제목 표시.
/// 입력: [text] 제목
/// 사용처: DetailPage의 "소개/갤러리/지도/리뷰" 섹션 헤더.
/// 비고: SliverToBoxAdapter로 감싸 scroll 영역에 자연스럽게 배치.

// lib/features/foryou/presentation/widgets/section_title.dart
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
