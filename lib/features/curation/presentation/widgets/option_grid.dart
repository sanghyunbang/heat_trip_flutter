import 'package:flutter/material.dart';

/// WHAT: 2열 카드 그리드(이모지+라벨) 기본 위젯
/// WHY: 공간/사회성/소음/혼잡/실내외/여행목적 등 동일한 패턴을 재사용하기 위함

typedef OnSelect = void Function(String value);

class OptionGrid extends StatelessWidget {
  final String title; // 섹션 제목(예: "공간")
  final List<_OptionItem> items; // 선택 항목 리스트
  final String? selected; // 현재 선택된 값
  final OnSelect onSelect; // 선택 시 콜백

  const OptionGrid({
    super.key,
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: items
              .map(
                (e) => _SelectableCard(
                  emoji: e.emoji,
                  label: e.label,
                  selected: selected == e.value,
                  onTap: () => onSelect(e.value),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _OptionItem {
  final String value; // 내부 식별자
  final String emoji; // UX용 이모지
  final String label; // 사용자 노출 라벨
  const _OptionItem(this.value, this.emoji, this.label);
}

class _SelectableCard extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SelectableCard({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFA37B5C) : const Color(0xFFF2EDDC);
    final fg = selected ? Colors.white : const Color(0xFF2D2A26);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// === 각 섹션별 팩토리 위젯(읽기 쉬운 API) ===
class SpaceGrid extends OptionGrid {
  SpaceGrid({super.key, required String? selected, required OnSelect onSelect})
    : super(
        title: '공간',
        selected: selected,
        onSelect: onSelect,
        items: const [
          _OptionItem('cozy', '🏡', '아늑함'),
          _OptionItem('open', '🏞️', '개방적'),
        ],
      );
}

class SocialityGrid extends OptionGrid {
  SocialityGrid({
    super.key,
    required String? selected,
    required OnSelect onSelect,
  }) : super(
         title: '사회성',
         selected: selected,
         onSelect: onSelect,
         items: const [
           _OptionItem('alone', '👤', '혼자'),
           _OptionItem('with-people', '👥', '함께'),
         ],
       );
}

class NoiseGrid extends OptionGrid {
  NoiseGrid({super.key, required String? selected, required OnSelect onSelect})
    : super(
        title: '소음도',
        selected: selected,
        onSelect: onSelect,
        items: const [
          _OptionItem('quiet', '🤫', '조용함'),
          _OptionItem('loud', '🎉', '활기참'),
        ],
      );
}

class CongestionGrid extends OptionGrid {
  CongestionGrid({
    super.key,
    required String? selected,
    required OnSelect onSelect,
  }) : super(
         title: '혼잡도',
         selected: selected,
         onSelect: onSelect,
         items: const [
           _OptionItem('empty', '🧘‍♀️', '여유로움'),
           _OptionItem('crowded', '🏙️', '분주함'),
         ],
       );
}

class InOutGrid extends OptionGrid {
  InOutGrid({super.key, required String? selected, required OnSelect onSelect})
    : super(
        title: '실내/실외',
        selected: selected,
        onSelect: onSelect,
        items: const [
          _OptionItem('indoor', '🏠', '실내'),
          _OptionItem('outdoor', '🌳', '실외'),
        ],
      );
}

class TravelPurposeGrid extends OptionGrid {
  TravelPurposeGrid({
    super.key,
    required String? selected,
    required OnSelect onSelect,
  }) : super(
         title: '여행 목적',
         selected: selected,
         onSelect: onSelect,
         items: const [
           _OptionItem('relaxation', '🌿', '진정/이완'),
           _OptionItem('mood-enhancement', '🥳', '기분상향'),
           _OptionItem('immersion', '🧐', '몰입'),
           _OptionItem('social-connection', '🤝', '사회적 연결'),
           _OptionItem('perspective-shift', '💡', '관점전환'),
           _OptionItem('meaning-reflection', '💭', '의미/성찰'),
         ],
       );
}
