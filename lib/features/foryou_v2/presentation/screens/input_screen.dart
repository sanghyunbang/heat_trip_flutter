import 'package:flutter/material.dart';
import '../../domain/models.dart';

// ================================================================
// InputScreen (리뉴얼 + 리팩토링)
// - 문자열 Sanitizer 추가: Android JNI(Modified UTF-8) 안전 전송용
// - 이모지(emoji)는 UI 전용으로만 사용하고, 전송 파라미터에서는 제외
// - State 인스턴스 생성 안티패턴 제거(스타일 분리: InputStyles)
// - 주석 꼼꼼히 추가
// ================================================================

// ⚙️ 문자열 Sanitizer: Android JNI가 거부하는 NUL(\u0000) 등 제어문자 방어
String sanitizeForAndroid(String? s) {
  if (s == null) return '';
  final filtered = s.runes.map((cp) {
    // NUL(0x0000) → replacement char
    if (cp == 0x0000) return 0xFFFD;
    // (필요시) 단독 서러게이트 방어 등 추가 룰을 여기서 확장 가능
    return cp;
  });
  return String.fromCharCodes(filtered);
}

// 🎨 스타일: State와 분리하여 어디서든 안전하게 재사용
class InputStyles {
  static const Color kBgWarm = Color(0xFFFFFAF8);
  static const Color kCard = Colors.white;
  static const Color kTextPrimary = Color(0xFF342D2A);
  static const Color kTextSecondary = Color(0xFF7B6E67);
  static const Color kAccent = Color(0xFFFB6A3E);
  static const Color kAccentSoft = Color(0xFFFFE7E0);
  static const Color kBorder = Color(0xFFEBD9D2);

  static BoxDecoration sectionBox() => BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
}

/// 입력 화면 (디자인 리뉴얼 + 레이아웃 리팩터링)
class InputScreen extends StatefulWidget {
  final RankRequest initial;
  const InputScreen({super.key, required this.initial});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  // 값 상태(기존 로직 유지)
  late double p, a, d, energy, social;
  String? moodKey; // ★ 서버 전송용 텍스트(예: '기쁨', '슬픔')
  String? moodEmoji; // ★ UI 전용 (전송 금지)
  late TextEditingController notesCtrl;

  // 목적 키워드(기존 로직 유지)
  final TextEditingController keywordCtrl = TextEditingController();
  final List<String> purposeKeywords = [];

  // 주요 감정(키-이모지) 프리셋(6개 → 3x2 그리드)
  static const _moods = <(String key, String emoji)>[
    ('기쁨', '😊'),
    ('슬픔', '😢'),
    ('불안', '😰'),
    ('분노', '😡'),
    ('평온', '😌'),
    ('설렘', '✨'),
  ];

  // 섹션 카드 공통 데코 (스타일 재사용)
  BoxDecoration get _sectionBox => InputStyles.sectionBox();

  @override
  void initState() {
    super.initState();
    p = widget.initial.pad.pleasure;
    a = widget.initial.pad.arousal;
    d = widget.initial.pad.dominance;
    energy = widget.initial.energy;
    social = widget.initial.socialNeed;
    moodKey = widget.initial.moodKey;
    moodEmoji = widget.initial.moodEmoji; // UI에서만 사용
    notesCtrl = TextEditingController(text: widget.initial.notes ?? '');
    purposeKeywords.addAll(widget.initial.purposeKeywords);
  }

  @override
  void dispose() {
    notesCtrl.dispose();
    keywordCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => (moodKey != null && moodKey!.trim().isNotEmpty);

  // 섹션 헤더(타이틀 표준화)
  Widget _sectionHeader({
    required String title,
    String? subtitle,
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null)
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7B42), Color(0xFFFF5670)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        if (icon != null) const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 13.0,
                  color: InputStyles.kTextPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.0,
                    color: InputStyles.kTextSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // 따뜻한 그라데이션 헤더(스크린 최상단)
  Widget _introBanner() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFB07A).withOpacity(.28),
            const Color(0xFFFF9FB2).withOpacity(.22),
            const Color(0xFFFFE4D6).withOpacity(.50),
          ],
        ),
        border: Border.all(color: const Color(0xFFFFE1D6)),
      ),
      child: _sectionHeader(
        icon: Icons.auto_awesome,
        title: '당신의 감정을 알려주세요',
        subtitle: '현재 느끼는 감정을 솔직하게 입력해주세요. AI가 당신에게 딱 맞는 여행지를 찾아드립니다.',
      ),
    );
  }

  // 주감정 선택(필수) — 3x2 그리드
  Widget _moodSection() {
    return Container(
      decoration: _sectionBox,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: '주감정 선택',
            subtitle: '지금 가장 강하게 느끼는 감정을 선택하세요.',
            icon: Icons.emoji_emotions_outlined,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.2, // 가로형 칩 모양
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _moods.map((m) {
              final selected = moodKey == m.$1;
              return ChoiceChip(
                label: Text(
                  '${m.$2} ${m.$1}', // 이모지는 UI 레이블에만 사용
                  style: const TextStyle(fontSize: 12.5),
                ),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    moodKey = m.$1;   // 서버 전송용 텍스트
                    moodEmoji = m.$2; // UI 표시용(전송 금지)
                  });
                },
                selectedColor: InputStyles.kAccentSoft,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: selected ? InputStyles.kAccent : InputStyles.kTextPrimary,
                ),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: selected ? InputStyles.kAccent : InputStyles.kBorder,
                    width: selected ? 1.6 : 1.0,
                  ),
                ),
                elevation: selected ? 1.5 : 0,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
          if (!_canSubmit) ...[
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.info_outline, size: 16, color: Colors.redAccent),
                SizedBox(width: 6),
                Text(
                  '주요 감정을 선택해야 계속할 수 있어요.',
                  style: TextStyle(fontSize: 12, color: Colors.redAccent),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 공용 슬라이더 카드(디자인만 개선, 값/범위/로직은 기존 유지)
  Widget _sliderCard({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    required String left,
    required String right,
    IconData? icon,
  }) {
    return Container(
      decoration: _sectionBox,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: InputStyles.kAccent, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 13.0,
                  color: InputStyles.kTextPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: InputStyles.kAccentSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD0C2)),
                ),
                child: Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: InputStyles.kAccent,
              inactiveTrackColor: Colors.black12,
              thumbColor: InputStyles.kAccent,
              overlayColor: InputStyles.kAccent.withOpacity(.12),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value,
              min: -1,
              max: 1,
              divisions: 20, // -1..1 범위에서 0.1 step
              onChanged: (v) => setState(() => onChanged(double.parse(v.toStringAsFixed(1)))),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(left, style: const TextStyle(color: InputStyles.kTextSecondary, fontSize: 11.5)),
              Text(right, style: const TextStyle(color: InputStyles.kTextSecondary, fontSize: 11.5)),
            ],
          ),
        ],
      ),
    );
  }

  // PAD 섹션(슬라이더 3개)
  Widget _padSection() {
    return Container(
      decoration: _sectionBox.copyWith(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF1EA), Colors.white],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: '감정 세부 조정',
            subtitle: '선택한 감정을 더 정확하게 표현해 보세요.',
            icon: Icons.tune,
          ),
          const SizedBox(height: 12),
          _sliderCard(
            title: '즐거움 (Pleasure)',
            value: p,
            onChanged: (v) => p = v,
            left: '불쾌함',
            right: '매우 즐거움',
            icon: Icons.sentiment_satisfied_alt_outlined,
          ),
          const SizedBox(height: 10),
          _sliderCard(
            title: '각성 (Arousal)',
            value: a,
            onChanged: (v) => a = v,
            left: '차분함',
            right: '흥분됨',
            icon: Icons.flash_on_outlined,
          ),
          const SizedBox(height: 10),
          _sliderCard(
            title: '주도성 (Dominance)',
            value: d,
            onChanged: (v) => d = v,
            left: '수동적',
            right: '주도적',
            icon: Icons.psychology_outlined,
          ),
        ],
      ),
    );
  }

  // 추가 정보 카드 (에너지/사교 묶음)
  Widget _extraInfoSection() {
    return AdditionalInfoCard(
      energy: energy,
      social: social,
      onEnergyChanged: (v) => setState(() => energy = double.parse(v.toStringAsFixed(1))),
      onSocialChanged: (v) => setState(() => social = double.parse(v.toStringAsFixed(1))),
    );
  }

  // 키워드/메모 섹션 — 큰 바깥 카드
  Widget _keywordsAndNotesSection() {
    return Container(
      decoration: _sectionBox,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: '목적 키워드 & 메모',
            subtitle: '여행 목적 키워드와 추가 메모를 입력하세요.',
            icon: Icons.edit_note_outlined,
          ),
          const SizedBox(height: 12),
          const Text(
            '목적 키워드',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: InputStyles.kTextPrimary,
              fontSize: 12.0,
            ),
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
                    hintStyle: TextStyle(
                      fontSize: 10.5,
                      color: InputStyles.kTextSecondary,
                    ),
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
                style: FilledButton.styleFrom(
                  backgroundColor: InputStyles.kAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onPressed: () {
                  final t = keywordCtrl.text.trim();
                  if (t.isNotEmpty) {
                    setState(() {
                      purposeKeywords.add(t);
                      keywordCtrl.clear();
                    });
                  }
                },
                child: const Text('추가', style: TextStyle(fontSize: 12.0)),
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
                    label: Text(k, style: const TextStyle(fontSize: 12.0)),
                    onDeleted: () => setState(() => purposeKeywords.remove(k)),
                    backgroundColor: InputStyles.kAccentSoft,
                    shape: StadiumBorder(
                      side: BorderSide(color: const Color(0xFFFFD0C2)),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            '추가 메모 (선택사항)',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: InputStyles.kTextPrimary,
              fontSize: 12.0,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: notesCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              hintText: '현재 상황이나 특별히 원하는 것이 있다면 자유롭게 작성해주세요.',
              hintStyle: TextStyle(
                fontSize: 10.5,
                color: InputStyles.kTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).viewPadding;

    return Scaffold(
      backgroundColor: InputStyles.kBgWarm,
      appBar: AppBar(
        elevation: 0.6,
        backgroundColor: Colors.white,
        title: const Text(
          '감정 입력',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 20 + pad.bottom),
          children: [
            _introBanner(),
            const SizedBox(height: 12),
            _moodSection(),
            const SizedBox(height: 12),
            _padSection(),
            const SizedBox(height: 12),
            _extraInfoSection(),
            const SizedBox(height: 12),
            _keywordsAndNotesSection(),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                backgroundColor: _canSubmit ? InputStyles.kAccent : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _canSubmit
                  ? () {
                      // ✅ 전송 직전: 모든 문자열 sanitize
                      final cleanedNotes = sanitizeForAndroid(notesCtrl.text.trim());
                      final cleanedKeywords = purposeKeywords
                          .map((k) => sanitizeForAndroid(k.trim()))
                          .where((k) => k.isNotEmpty)
                          .toList();
                      final cleanedMoodKey = sanitizeForAndroid(moodKey);

                      // ✅ UI 전용 이모지는 전송 금지: moodEmoji를 명시적으로 null 처리
                      final updated = widget.initial.copyWith(
                        pad: Pad(pleasure: p, arousal: a, dominance: d),
                        energy: energy,
                        socialNeed: social,
                        notes: cleanedNotes.isEmpty ? null : cleanedNotes,
                        purposeKeywords: cleanedKeywords,
                        moodKey: cleanedMoodKey, // 서버 필요 값(텍스트)
                        moodEmoji: null,         // ⚠️ 전송 금지 (UI 전용)
                      );

                      // 상위로 sanitized 데이터 전달
                      Navigator.pop(context, updated);
                    }
                  : null,
              child: const Text(
                '분석 시작하기',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 추가 정보 카드: 에너지/사교 묶음 (State 생성 안티패턴 제거)
class AdditionalInfoCard extends StatelessWidget {
  final double energy; // -1 ~ 1
  final double social; // -1 ~ 1
  final ValueChanged<double> onEnergyChanged;
  final ValueChanged<double> onSocialChanged;

  const AdditionalInfoCard({
    super.key,
    required this.energy,
    required this.social,
    required this.onEnergyChanged,
    required this.onSocialChanged,
  });

  @override
  Widget build(BuildContext context) {
    final box = InputStyles.sectionBox();
    return Container(
      decoration: box,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            icon: Icons.info_outline,
            title: '추가 정보',
            subtitle: '지금의 컨디션을 간단히 표시하세요.',
          ),
          const SizedBox(height: 12),
          _LabeledSlider(
            title: '에너지 상태',
            value: energy,
            leftLabel: '피곤함',
            rightLabel: '활기참',
            icon: Icons.battery_3_bar,
            onChanged: onEnergyChanged,
          ),
          const SizedBox(height: 12),
          _LabeledSlider(
            title: '사교성',
            value: social,
            leftLabel: '혼자 있고 싶음',
            rightLabel: '사람들과 함께',
            icon: Icons.group_outlined,
            onChanged: onSocialChanged,
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const _CardHeader({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: InputStyles.kAccent, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: InputStyles.kTextPrimary,
                  fontSize: 13.0,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: InputStyles.kTextSecondary,
                    fontSize: 11.0,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  final String title;
  final double value; // -1 ~ 1
  final String leftLabel;
  final String rightLabel;
  final IconData icon;
  final ValueChanged<double> onChanged;

  const _LabeledSlider({
    required this.title,
    required this.value,
    required this.leftLabel,
    required this.rightLabel,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: InputStyles.kAccent, size: 18),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: InputStyles.kTextPrimary,
                fontSize: 13.0,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: InputStyles.kAccentSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${((value + 1) * 50).round()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: InputStyles.kAccent,
            inactiveTrackColor: Colors.black12,
            thumbColor: InputStyles.kAccent,
            overlayColor: InputStyles.kAccent.withOpacity(.12),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: -1,
            max: 1,
            divisions: 20,
            onChanged: (v) => onChanged(double.parse(v.toStringAsFixed(1))),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leftLabel,
              style: const TextStyle(
                color: InputStyles.kTextSecondary,
                fontSize: 11.5,
              ),
            ),
            Text(
              rightLabel,
              style: const TextStyle(
                color: InputStyles.kTextSecondary,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
