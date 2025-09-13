/// "나의 경험" 탭
/// - 방문 전/후 감정 원형 칩 선택
/// - 공간 특성 슬라이더(0~1, 10단계)
/// - 텍스트 입력 + 제출 버튼
///
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/detail_emotion_vm.dart';
import 'emotion_tab.dart' show EMOTIONS; // 감정 라벨/이모지 재사용

class FeedbackTab extends StatelessWidget {
  const FeedbackTab({super.key});

  // 디자인 토큰 (기능 영향 없음)
  static const _brand = Color(0xFFEB9C64);
  static const _muted = Color(0xFF6B7280);
  static const _chipBorder = Color(0xFFE6E6E6);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailEmotionVM>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('방문 전 감정 상태'),
        const SizedBox(height: 8),
        // 방문 전 감정 선택 — 원형 칩 디자인
        Center(
        child: Wrap(
          spacing: 14,
          runSpacing: 16,
          children: EMOTIONS.map((e) {
            final selected = vm.beforeEmotionId == e.id;
            return _RoundChip(
              emoji: e.emoji,
              label: e.name,
              selected: selected,
              onTap: () => vm.setBefore(e.id),
            );
          }).toList(),
        ),
        ),

        const SizedBox(height: 32),

        _sectionTitle('방문 후 어떤 기분이 되고 싶나요?'),
        const SizedBox(height: 8),
        // 방문 후 감정 선택 — 원형 칩 디자인
        Center(
        child: Wrap(
          spacing: 14,
          runSpacing: 16,
          children: EMOTIONS.map((e) {
            final selected = vm.afterEmotionId == e.id;
            return _RoundChip(
              emoji: e.emoji,
              label: e.name,
              selected: selected,
              onTap: () => vm.setAfter(e.id),
            );
          }).toList(),
        ),
        ),

        const SizedBox(height: 8),
        const Divider(height: 48),

        _sectionTitle('이 공간의 특성을 평가해주세요'),
        const SizedBox(height: 8),
        // 각 특성 슬라이더 (0~1) — 로직 그대로, 스타일만
        ...vm.userFeatureRatings.entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  _k2label(e.key),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _brand,
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: _brand,
                    overlayColor: _brand.withOpacity(.15),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                  ),
                  child: Slider(
                    value: e.value,
                    onChanged: (v) => vm.setFeature(e.key, v),
                    min: 0,
                    max: 1,
                    divisions: 10,
                  ),
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '${(e.value * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: _muted),
                ),
              ),
            ],
          ),
        )),

        const Divider(height: 32),
        const SizedBox(height: 6),

        _sectionTitle('상세 경험 (선택)'),
        // 자유 텍스트 — 테두리/힌트톤만 정리
        TextField(
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: '감정적 경험을 자유롭게 적어주세요',
            hintStyle: const TextStyle(color: _muted),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEDEDED)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _brand, width: 1.2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onChanged: vm.setText,
        ),
        const SizedBox(height: 28),

        // 제출 버튼: 방문 전/후 감정이 모두 선택되어야 활성화 (로직 동일)
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: (vm.beforeEmotionId == null || vm.afterEmotionId == null)
                ? null
                : () async {
              await vm.submit();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('경험을 공유했어요. 고마워요!')),
                );
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('경험 공유하기'),
            style: FilledButton.styleFrom(
              backgroundColor: _brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: const Color(0xFFEDEDED),
              disabledForegroundColor: const Color(0xFF9AA0A6),
            ),
          ),
        ),
      ],
    );
  }

  /// 섹션 타이틀 공통 위젯 (디자인만)
  Widget _sectionTitle(String s) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      s,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
    ),
  );

  /// 내부 키 → 한글 라벨 (로직 그대로)
  String _k2label(String k) {
    switch (k) {
      case 'sociality': return '사교성';
      case 'spirituality': return '영적 체험';
      case 'adventure': return '모험성';
      case 'culture': return '문화성';
      case 'nature_healing': return '자연치유';
      case 'quiet': return '고요함';
      default: return k;
    }
  }
}

/// ───────────────────────── 레퍼런스 기반 원형 칩 위젯 ─────────────────────────
/// 참고한 “여행 타입” UI와 동일한 컨셉: 동그란 아이콘 캡슐 + 라벨, 선택 시 보더/배경 강조
class _RoundChip extends StatelessWidget {
  const _RoundChip({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _brand = Color(0xFFEB9C64);
  static const _chipBorder = Color(0xFFE6E6E6);
  static const _text = Color(0xFF353535);

  @override
  Widget build(BuildContext context) {
    final bg = selected ? _brand.withOpacity(.12) : const Color(0xFFF8F8F9);
    final border = selected ? _brand : _chipBorder;
    final emojiText = Text(
      emoji,
      style: const TextStyle(fontSize: 22),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 원형 아이콘 캡슐
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(color: border, width: 1.2),
            ),
            alignment: Alignment.center,
            child: emojiText,
          ),
          const SizedBox(height: 6),
          // 라벨
          SizedBox(
            width: 72,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected ? _brand : _text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
