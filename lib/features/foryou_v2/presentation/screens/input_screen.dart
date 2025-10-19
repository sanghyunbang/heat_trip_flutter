import 'package:flutter/material.dart';
import '../../domain/models.dart';

/// 입력 화면: 주요 감정 + PAD/에너지/사교/키워드/메모
/// - 주요 감정 선택이 *필수*
/// - 선택하지 않으면 제출 버튼 비활성화
class InputScreen extends StatefulWidget {
  final RankRequest initial;
  const InputScreen({super.key, required this.initial});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  // 값 상태
  late double p, a, d, energy, social;
  String? moodKey; // ★ 필수
  String? moodEmoji; // 선택(표시용)
  late TextEditingController notesCtrl;

  // 목적 키워드
  final TextEditingController keywordCtrl = TextEditingController();
  final List<String> purposeKeywords = [];

  // 주요 감정(키-이모지) 프리셋
  static const _moods = <(String key, String emoji)>[
    ('우울', '🌧️'),
    ('불안', '⚡'),
    ('분노', '🔥'),
    ('지침', '🥱'),
    ('평온', '🌿'),
    ('설렘', '✨'),
  ];

  @override
  void initState() {
    super.initState();
    p = widget.initial.pad.pleasure;
    a = widget.initial.pad.arousal;
    d = widget.initial.pad.dominance;
    energy = widget.initial.energy;
    social = widget.initial.socialNeed;
    moodKey = widget.initial.moodKey; // 초기값 반영
    moodEmoji = widget.initial.moodEmoji; // 초기값 반영
    notesCtrl = TextEditingController(text: widget.initial.notes ?? '');
    purposeKeywords.addAll(widget.initial.purposeKeywords);
  }

  @override
  void dispose() {
    notesCtrl.dispose();
    keywordCtrl.dispose();
    super.dispose();
  }

  // 공용 슬라이더 카드
  Widget _sliderCard({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    required String left,
    required String right,
    IconData? icon,
  }) {
    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.deepOrange),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3EE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(value.toStringAsFixed(1)),
                ),
              ],
            ),
            Slider(
              value: value,
              min: -1,
              max: 1,
              divisions: 20,
              activeColor: Colors.deepOrange,
              inactiveColor: Colors.black12,
              onChanged: (v) =>
                  setState(() => onChanged(double.parse(v.toStringAsFixed(1)))),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  left,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                Text(
                  right,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSubmit => (moodKey != null && moodKey!.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      appBar: AppBar(
        elevation: 0.6,
        title: const Text('감정 입력'),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // ★ 헤더 + 주요 감정 선택(필수)
          Card(
            elevation: 0.6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤드
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7B42), Color(0xFFFF5670)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                      ),
                    ),
                    title: const Text(
                      '당신의 감정을 알려주세요',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      '주요 감정을 먼저 선택한 뒤, PAD/에너지/사교/키워드를 입력하세요.',
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    '주요 감정 (필수)',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _moods.map((m) {
                      final selected = moodKey == m.$1;
                      return ChoiceChip(
                        label: Text('${m.$2} ${m.$1}'),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            moodKey = m.$1;
                            moodEmoji = m.$2;
                          });
                        },
                        selectedColor: const Color(0xFFFFE7E0),
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: selected
                                ? Colors.deepOrange
                                : Colors.orange.shade200,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  if (!_canSubmit) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '주요 감정을 선택해야 계속할 수 있어요.',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // PAD 슬라이더들
          _sliderCard(
            title: 'Pleasure (즐거움)',
            value: p,
            onChanged: (v) => p = v,
            left: '불쾌',
            right: '매우 즐거움',
            icon: Icons.sentiment_satisfied_alt_outlined,
          ),
          _sliderCard(
            title: 'Arousal (각성)',
            value: a,
            onChanged: (v) => a = v,
            left: '차분함',
            right: '흥분됨',
            icon: Icons.flash_on_outlined,
          ),
          _sliderCard(
            title: 'Dominance (주도성)',
            value: d,
            onChanged: (v) => d = v,
            left: '수동적',
            right: '주도적',
            icon: Icons.psychology_outlined,
          ),
          _sliderCard(
            title: 'Energy (에너지)',
            value: energy,
            onChanged: (v) => energy = v,
            left: '피곤함',
            right: '활기참',
            icon: Icons.battery_3_bar,
          ),
          _sliderCard(
            title: 'Social (사교성)',
            value: social,
            onChanged: (v) => social = v,
            left: '혼자',
            right: '함께',
            icon: Icons.group_outlined,
          ),

          // 키워드/메모 카드
          Card(
            elevation: 0.6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '목적 키워드',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: keywordCtrl,
                          decoration: const InputDecoration(
                            hintText: '예) 자연치유, 조용한산책',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) {
                            final t = keywordCtrl.text.trim();
                            if (t.isNotEmpty) {
                              setState(() {
                                purposeKeywords.add(t);
                                keywordCtrl.clear();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          final t = keywordCtrl.text.trim();
                          if (t.isNotEmpty) {
                            setState(() {
                              purposeKeywords.add(t);
                              keywordCtrl.clear();
                            });
                          }
                        },
                        child: const Text('추가'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: purposeKeywords
                        .map(
                          (k) => Chip(
                            label: Text(k),
                            onDeleted: () =>
                                setState(() => purposeKeywords.remove(k)),
                            backgroundColor: const Color(0xFFFFF3EE),
                            shape: StadiumBorder(
                              side: BorderSide(color: Colors.orange.shade200),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '메모 (선택)',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      hintText: '현재 상황/감정 등을 자유롭게 표현해주세요.',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 제출 버튼 (주요 감정 미선택 시 비활성화)
          FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: _canSubmit
                  ? const Color(0xFFFB6A3E)
                  : Colors.grey,
            ),
            onPressed: _canSubmit
                ? () {
                    final updated = widget.initial.copyWith(
                      pad: Pad(pleasure: p, arousal: a, dominance: d),
                      energy: energy,
                      socialNeed: social,
                      notes: notesCtrl.text.trim().isEmpty
                          ? null
                          : notesCtrl.text.trim(),
                      purposeKeywords: purposeKeywords,
                      moodKey: moodKey, // ★ 서버에 필요
                      moodEmoji: moodEmoji, // UI 표시용
                    );
                    Navigator.pop(context, updated);
                  }
                : null,
            child: const Text(
              '분석 시작하기',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
