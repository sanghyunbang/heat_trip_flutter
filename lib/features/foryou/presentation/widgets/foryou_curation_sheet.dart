import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/common/goal_labels.dart';
import '../../domain/entities.dart';

class ForYouCurationSheet extends StatefulWidget {
  const ForYouCurationSheet({super.key, required this.initial});
  final RankRequest initial;

  @override
  State<ForYouCurationSheet> createState() => _ForYouCurationSheetState();
}

class _ForYouCurationSheetState extends State<ForYouCurationSheet> {
  // PAD
  late double p, a, d;
  late int energy;
  late double socialNeed;
  late Set<String> goals;

  // 🆕 사용자 선택 감정(이모지 고정용)
  String? selectedMoodKey; // ex) '기쁨'
  String? selectedMoodEmoji; // ex) '😊'

  // 파스텔 팔레트 ───────────────────────────────────────────────────────────
  static const Color _pastelGreenBase = Color.fromARGB(255, 143, 218, 145);
  static const Color _pastelOrangeBase = Color.fromARGB(255, 245, 190, 96);
  static const Color _pastelIndigoBase = Color.fromARGB(255, 154, 166, 235);
  static const Color _pastelBlueBase = Color(0xFF2196F3);
  static const Color _pastelPurpleBase = Color(0xFF9C27B0);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF2D3748);
  static const Color _textSecondary = Color(0xFF4A5568);

  // energy preset ───────────────────────────────────────────────────────────
  static const _mintBase = Color(0xFF5FB3A6);
  static const _mintBorder = Color(0xFF7FC5BA);
  static const _mintShadow = Color(0xFF4FA99C);
  static const _mintBgBase = Color(0xFFBFE5DE);
  static const _selBase = _mintBase;
  static const _selBorder = _mintBorder;
  static const _selShadow = _mintShadow;
  static const _selBgBase = _mintBgBase;

  // 감정 → PAD 매핑 ────────────────────────────────────────────────────────
  static const Map<String, Map<String, dynamic>> moodToPad = {
    "기쁨": {"emoji": "😊", "p": 2.0, "a": 1.0, "d": 1.0},
    "흥분": {"emoji": "🤩", "p": 2.0, "a": 2.0, "d": 1.0},
    "평온": {"emoji": "😌", "p": 1.0, "a": -1.0, "d": 1.0},
    "만족": {"emoji": "😇", "p": 2.0, "a": 0.0, "d": 2.0},
    "불안": {"emoji": "😰", "p": -2.0, "a": 2.0, "d": -2.0},
    "우울": {"emoji": "😞", "p": -2.0, "a": -1.0, "d": -2.0},
    "분노": {"emoji": "😠", "p": -2.0, "a": 2.0, "d": 1.0},
    "무기력": {"emoji": "😴", "p": -1.5, "a": -2.0, "d": -2.0},
  };

  // PAD에 가장 가까운 감정 (선택값 없을 때 초기 표시용)
  String _closestMood() {
    double minDist = double.infinity;
    String best = "기쁨";
    for (final e in moodToPad.entries) {
      final mp = e.value["p"] as double;
      final ma = e.value["a"] as double;
      final md = e.value["d"] as double;
      final dp = p - mp, da = a - ma, dd = d - md;
      final dist = dp * dp + da * da + dd * dd;
      if (dist < minDist) {
        minDist = dist;
        best = e.key;
      }
    }
    return best;
  }

  @override
  void initState() {
    super.initState();
    p = widget.initial.pad.pleasure;
    a = widget.initial.pad.arousal;
    d = widget.initial.pad.dominance;
    energy = widget.initial.energy;
    socialNeed = widget.initial.socialNeed;
    // ✅ goals는 정규화해서 들고다니면 안전
    goals = widget.initial.goals.map(normalizeGoalKey).toSet();

    selectedMoodKey = widget.initial.moodKey ?? _closestMood();
    selectedMoodEmoji =
        widget.initial.moodEmoji ??
        (moodToPad[selectedMoodKey]?["emoji"] as String? ?? '🙂');
  }

  void _toggleGoal(String k) =>
      setState(() => goals.contains(k) ? goals.remove(k) : goals.add(k));

  // 감정 선택 + PAD 미세조정 UI
  Widget _moodSelector() {
    final highlighted = selectedMoodKey!;
    final entries = moodToPad.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '현재 감정 상태',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '감정을 선택하면 PAD 기본값이 설정되며, 아래 슬라이더로 0.1 단위로 조정할 수 있어요.',
          style: TextStyle(fontSize: 13, color: Color(0xFF718096)),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: [for (final e in entries) _buildMoodCard(e, highlighted)],
        ),
        const SizedBox(height: 20),
        _padFineTuner(),
      ],
    );
  }

  Widget _buildMoodCard(
    MapEntry<String, Map<String, dynamic>> entry,
    String highlighted,
  ) {
    final moodName = entry.key;
    final moodData = entry.value;
    final emoji = moodData["emoji"] as String;
    final isSelected = moodName == highlighted;

    final cardWidth = (MediaQuery.of(context).size.width - 20 - 20 - 8 * 3) / 4;

    return SizedBox(
      width: cardWidth,
      child: GestureDetector(
        onTap: () {
          setState(() {
            p = moodData["p"] as double;
            a = moodData["a"] as double;
            d = moodData["d"] as double;
            selectedMoodKey = moodName;
            selectedMoodEmoji = emoji;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? _pastelBlueBase.withValues(alpha: 0.12)
                : _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? _pastelBlueBase.withValues(alpha: 0.55)
                  : Colors.grey.withValues(alpha: 0.20),
              width: isSelected ? 2.2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? _pastelBlueBase.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: TextStyle(fontSize: isSelected ? 36 : 32)),
              const SizedBox(height: 6),
              Text(
                moodName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? _pastelBlueBase : _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _padFineTuner() {
    Widget sliderRow({
      required String label,
      required double value,
      required ValueChanged<double> onChanged,
      required IconData icon,
      required Color base,
    }) {
      final active = base.withValues(alpha: 0.75);
      final overlay = base.withValues(alpha: 0.14);
      final chipBg = base.withValues(alpha: 0.10);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: active),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  _miniIconButton(Icons.remove, () {
                    final v = (value - 0.1).clamp(-2.0, 2.0);
                    onChanged(double.parse(v.toStringAsFixed(1)));
                  }),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: active,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _miniIconButton(Icons.add, () {
                    final v = (value + 0.1).clamp(-2.0, 2.0);
                    onChanged(double.parse(v.toStringAsFixed(1)));
                  }),
                ],
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: active,
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.25),
              thumbColor: active,
              overlayColor: overlay,
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value,
              min: -2.0,
              max: 2.0,
              divisions: 40,
              label: value.toStringAsFixed(1),
              onChanged: (v) => onChanged(double.parse(v.toStringAsFixed(1))),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _pastelBlueBase.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          sliderRow(
            label: 'P (Pleasure)  나쁨 ↔ 좋음',
            value: p,
            onChanged: (v) => setState(() => p = v),
            icon: Icons.sentiment_satisfied,
            base: _pastelGreenBase,
          ),
          sliderRow(
            label: 'A (Arousal)  차분 ↔ 흥분',
            value: a,
            onChanged: (v) => setState(() => a = v),
            icon: Icons.flash_on,
            base: _pastelOrangeBase,
          ),
          sliderRow(
            label: 'D (Dominance)  수동 ↔ 능동',
            value: d,
            onChanged: (v) => setState(() => d = v),
            icon: Icons.psychology,
            base: _pastelIndigoBase,
          ),
        ],
      ),
    );
  }

  Widget _miniIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: _textSecondary),
      ),
    );
  }

  Widget _seg3(String title, int value, ValueChanged<int> onChanged) {
    const opts = [
      (-1, '낮음', Icons.battery_1_bar),
      (0, '보통', Icons.battery_3_bar),
      (1, '높음', Icons.battery_full),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: opts.map((opt) {
            final val = opt.$1;
            final label = opt.$2;
            final icon = opt.$3;
            final isSelected = val == value;

            final bg = isSelected
                ? _selBgBase.withValues(alpha: 0.22)
                : _surface;
            final brd = isSelected
                ? _selBorder.withValues(alpha: 0.60)
                : Colors.grey.withValues(alpha: 0.28);
            final txtC = isSelected
                ? _selBase.withValues(alpha: 0.95)
                : _textSecondary;
            final shd = isSelected
                ? _selShadow.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.02);

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => onChanged(val),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: brd, width: isSelected ? 2 : 1),
                      boxShadow: [
                        BoxShadow(
                          color: shd,
                          blurRadius: isSelected ? 6 : 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          icon,
                          color: isSelected
                              ? txtC
                              : Colors.grey.withValues(alpha: 0.70),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: txtC,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          val.toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final padInset = MediaQuery.of(context).viewPadding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('감정 인사이트 설정'),
        actions: [
          TextButton(
            onPressed: () {
              // ✅ 저장 직전 goals 정규화
              final normalizedGoals = goals.map(normalizeGoalKey).toSet();

              final updated = widget.initial.copyWith(
                pad: widget.initial.pad.copyWith(
                  pleasure: p,
                  arousal: a,
                  dominance: d,
                ),
                energy: energy,
                socialNeed: double.parse(socialNeed.toStringAsFixed(1)),
                goals: normalizedGoals.toList(),
                moodKey: selectedMoodKey,
                moodEmoji: selectedMoodEmoji,
              );
              Navigator.pop(context, updated);
            },
            child: const Text('저장'),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _pastelBlueBase.withValues(alpha: 0.03),
                _pastelPurpleBase.withValues(alpha: 0.03),
                _surface,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + padInset.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _moodSelector(),
                const SizedBox(height: 24),
                _seg3('에너지', energy, (v) => setState(() => energy = v)),
                const SizedBox(height: 24),
                const Text(
                  '사회성 필요도',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // 사회성 슬라이더
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: _pastelBlueBase.withValues(alpha: 0.80),
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '혼자',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(
                                Icons.groups,
                                color: _pastelBlueBase.withValues(alpha: 0.80),
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '함께',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: _pastelBlueBase.withValues(
                            alpha: 0.70,
                          ),
                          inactiveTrackColor: Colors.grey.withValues(
                            alpha: 0.28,
                          ),
                          thumbColor: _pastelBlueBase.withValues(alpha: 0.70),
                          overlayColor: _pastelBlueBase.withValues(alpha: 0.12),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12,
                          ),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: socialNeed,
                          min: -1,
                          max: 1,
                          divisions: 4,
                          label: socialNeed.toStringAsFixed(1),
                          onChanged: (v) => setState(
                            () =>
                                socialNeed = double.parse(v.toStringAsFixed(1)),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _pastelBlueBase.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          socialNeed.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _pastelBlueBase.withValues(alpha: 0.90),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 24),
                const Text(
                  '여행 목표',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kDefaultGoalKeys.map((key) {
                    final selected = goals.contains(key);
                    final label = kGoalLabels[key] ?? key;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      child: FilterChip(
                        label: Text(
                          label,
                          style: TextStyle(
                            color: selected ? _surface : _textSecondary,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        selected: selected,
                        selectedColor: _pastelPurpleBase.withValues(
                          alpha: 0.65,
                        ),
                        backgroundColor: _surface,
                        side: BorderSide(
                          color: selected
                              ? _pastelPurpleBase.withValues(alpha: 0.55)
                              : Colors.grey.withValues(alpha: 0.30),
                        ),
                        elevation: selected ? 3 : 1,
                        onSelected: (_) => _toggleGoal(key),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
