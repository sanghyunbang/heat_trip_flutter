import 'package:flutter/material.dart';

/// WHAT: PAD(쾌/활/우) 3개 축 선택 위젯 묶음
/// WHY: 한 곳에서 레이아웃/스타일/선택 로직을 재사용
class PadSelectionGroup extends StatelessWidget {
  final int pleasure; // -2,-1,1,2 (0=미선택)
  final int arousal; // -2,-1,1,2
  final int dominance; // -2,-1,1,2
  final void Function(int value) onSelectPleasure;
  final void Function(int value) onSelectArousal;
  final void Function(int value) onSelectDominance;

  const PadSelectionGroup({
    super.key,
    required this.pleasure,
    required this.arousal,
    required this.dominance,
    required this.onSelectPleasure,
    required this.onSelectArousal,
    required this.onSelectDominance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('러셀의 PAD 감정', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          '아래 버튼을 선택하여 현재 감정의 정도를 나타내세요.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        _PadRow(
          label: '불쾌해요 ↔️ 즐거워요',
          options: const [
            _PadOpt('😢', '-2', -2),
            _PadOpt('🙁', '-1', -1),
            _PadOpt('🙂', '+1', 1),
            _PadOpt('😁', '+2', 2),
          ],
          selected: pleasure,
          onSelect: onSelectPleasure,
        ),
        const SizedBox(height: 12),
        _PadRow(
          label: '침착해요 ↔️ 활기차요',
          options: const [
            _PadOpt('😴', '-2', -2),
            _PadOpt('😌', '-1', -1),
            _PadOpt('⚡', '+1', 1),
            _PadOpt('🔥', '+2', 2),
          ],
          selected: arousal,
          onSelect: onSelectArousal,
        ),
        const SizedBox(height: 12),
        _PadRow(
          label: '세상에 압도당해요 ↔️ 세상을 통제해요',
          options: const [
            _PadOpt('🥺', '-2', -2),
            _PadOpt('😥', '-1', -1),
            _PadOpt('💪', '+1', 1),
            _PadOpt('👑', '+2', 2),
          ],
          selected: dominance,
          onSelect: onSelectDominance,
        ),
      ],
    );
  }
}

class _PadRow extends StatelessWidget {
  final String label;
  final List<_PadOpt> options;
  final int selected;
  final void Function(int) onSelect;
  const _PadRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5ED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),

          // Wrap(
          //   alignment: WrapAlignment.center,
          //   spacing: 10,
          //   children: options
          //       .map(
          //         (o) => _padButton(
          //           context,
          //           emoji: o.emoji,
          //           text: o.label,
          //           value: o.value,
          //           isSelected: selected == o.value,
          //           onTap: () => onSelect(o.value),
          //         ),
          //       )
          //       .toList(),
          // ),

          //여기부터 교체 (Wrap 제거)
          Row(
            children: List.generate(options.length, (i) {
              final o = options[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 10),
                  child: _padButton(
                    context,
                    emoji: o.emoji,
                    text: o.label,
                    value: o.value,
                    isSelected: selected == o.value,
                    onTap: () => onSelect(o.value),
                  ),
                ),
              );
            }),
          ),

          // 여기까지 교체
        ],
      ),
    );
  }

  Widget _padButton(
    BuildContext context, {
    required String emoji,
    required String text,
    required int value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bg = isSelected ? const Color(0xFFA37B5C) : const Color(0xFFF2EDDC);
    final fg = isSelected ? Colors.white : const Color(0xFF2D2A26);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(text, style: TextStyle(color: fg)),
          ],
        ),
      ),
    );
  }
}

class _PadOpt {
  final String emoji;
  final String label;
  final int value; // -2,-1,1,2
  const _PadOpt(this.emoji, this.label, this.value);
}
