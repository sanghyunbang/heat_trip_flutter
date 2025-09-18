import 'package:flutter/material.dart';
import '../../domain/entities.dart';

/// ForYouCurationSheet
/// ─────────────────────────────────────────────────────────────────────────────
/// • 목적: 감정 이모지 선택 → PAD 기본값 자동 세팅 + 0.1 단위 미세 조정 UI 제공
/// • PAD 축: Pleasure(쾌락), Arousal(각성), Dominance(주도감)
/// • 범위: 각 축 -2.0 ~ 2.0 (0.1 step)
/// • 에너지: -1 / 0 / 1 (3분할), 사회성 필요도: -1.0 ~ 1.0 (0.5 step)
/// • 디자인: 파스텔 톤 컬러(차분), Wrap 기반 감정 카드, 슬라이더 미세 조정
///
/// 구현 포인트
/// 1) 최신 Flutter 경고 대응: Color.withOpacity() → Color.withValues(alpha: …)
///    - 정밀도 손실 방지 권고에 따라 전면 교체.
/// 2) 상태는 double( PAD ), int( energy ), double( socialNeed ), Set<String>( goals )
/// 3) UI 접근성: 현재 PAD에 가장 가까운 감정을 카드로 하이라이트.
/// 4) 엔티티 타입 주의: RankRequest.pad.* 가 int라면 저장 시 반올림/변환 필요.
///    (아래 저장 핸들러에 주석 첨부)
class ForYouCurationSheet extends StatefulWidget {
  const ForYouCurationSheet({super.key, required this.initial});
  final RankRequest initial;

  @override
  State<ForYouCurationSheet> createState() => _ForYouCurationSheetState();
}

class _ForYouCurationSheetState extends State<ForYouCurationSheet> {
  // ───────────────────────────────────────────────────────────────────────────
  // 상태값(State)
  // ───────────────────────────────────────────────────────────────────────────
  late double p, a, d; // PAD는 미세 조정을 위해 double로 보관
  late int energy; // -1 / 0 / 1 (세분화된 수준)
  late double socialNeed; // [-1.0, 1.0], 0.5 step
  late Set<String> goals; // 여행 목표(Chip 토글)

  // ───────────────────────────────────────────────────────────────────────────
  // 파스텔 컬러 팔레트(일관성 유지를 위해 상수로 정의)
  //  - alpha는 0~1, pastel은 0.08~0.25 근방 권장(배경 대비/가독성 고려)
  // ───────────────────────────────────────────────────────────────────────────
  static const Color _pastelGreenBase = Color.fromARGB(
    255,
    143,
    218,
    145,
  ); // P (긍정 연상)
  static const Color _pastelOrangeBase = Color.fromARGB(
    255,
    245,
    190,
    96,
  ); // A (각성/에너지)
  static const Color _pastelIndigoBase = Color.fromARGB(
    255,
    154,
    166,
    235,
  ); // D (주도/안정)
  static const Color _pastelBlueBase = Color(0xFF2196F3); // 정보/강조
  static const Color _pastelPurpleBase = Color(0xFF9C27B0); // 선택 Chip
  static const Color _surface = Colors.white; // 카드/슬라 겉면
  static const Color _textPrimary = Color(0xFF2D3748);
  static const Color _textSecondary = Color(0xFF4A5568);

  // ── Pastel Presets for ENERGY Selected State ───────────────────────────────
  // Mint: 상쾌·차분, 현대적 파스텔 민트
  static const _mintBase = Color(0xFF5FB3A6); // 텍스트/아이콘 포인트
  static const _mintBorder = Color(0xFF7FC5BA); // 보더
  static const _mintShadow = Color(0xFF4FA99C); // 섀도우 베이스(알파로 사용)
  static const _mintBgBase = Color(0xFFBFE5DE); // 배경용 톤다운(알파 섞어 사용)

  // Sage: 초록+회색 감쇠, 매우 차분/저채도
  static const _sageBase = Color(0xFF6B9C7D);
  static const _sageBorder = Color(0xFF8BB59A);
  static const _sageShadow = Color(0xFF5C8E6F);
  static const _sageBgBase = Color(0xFFD5E6DB);

  // Seafoam: 밝고 가벼운 파스텔, 민트보다 더 화사
  static const _seaBase = Color(0xFF64C0B3);
  static const _seaBorder = Color(0xFF90D2C8);
  static const _seaShadow = Color(0xFF4CAEA0);
  static const _seaBgBase = Color(0xFFCFECE8);

  // ── Pick your theme here (Mint/Sage/Seafoam) ───────────────────────────────
  // 아래 alias를 다른 프리셋으로 바꾸면 전체 에너지 선택색이 교체됩니다.
  static const _selBase = _mintBase;
  static const _selBorder = _mintBorder;
  static const _selShadow = _mintShadow;
  static const _selBgBase = _mintBgBase;

  // ───────────────────────────────────────────────────────────────────────────
  // 감정 → PAD 매핑 (현실적/일반적 경향치)
  //  - 분노: 저쾌락/고각성/상대적 고주도
  //  - 무기력: 저쾌락/저각성/저주도 (분노와 명확히 구분)
  // ───────────────────────────────────────────────────────────────────────────
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

  // 여행 목표(레이블/키). 레코드(포지셔널) 사용 → g.$1(key)/g.$2(label)
  static const _goalDefs = <(String, String)>[
    ('quiet_reflection', '고요/성찰'),
    ('meaning_reflection', '의미/성찰'),
    ('nature_healing', '자연 힐링'),
    ('adventure', '모험/활동'),
    ('culture', '문화/예술'),
    ('social', '교류/연결'),
    ('spiritual', '영성/명상'),
  ];

  // 현재 PAD와 가장 가까운 감정 키(이름)를 유클리드 거리로 산출
  String _getCurrentMood() {
    double minDistance = double.infinity;
    String closestMood = "기쁨";
    for (final entry in moodToPad.entries) {
      final mp = entry.value["p"] as double;
      final ma = entry.value["a"] as double;
      final md = entry.value["d"] as double;
      final dp = p - mp, da = a - ma, dd = d - md;
      final distance = dp * dp + da * da + dd * dd;
      if (distance < minDistance) {
        minDistance = distance;
        closestMood = entry.key;
      }
    }
    return closestMood;
  }

  @override
  void initState() {
    super.initState();
    // 초기 PAD는 전달받은 RankRequest에서 double로 변환하여 수용
    p = widget.initial.pad.pleasure.toDouble();
    a = widget.initial.pad.arousal.toDouble();
    d = widget.initial.pad.dominance.toDouble();
    energy = widget.initial.energy;
    socialNeed = widget.initial.socialNeed;
    goals = widget.initial.goals.toSet();
  }

  // Chip 토글 핸들러(불변/가변 Set 고려 → setState로 교체)
  void _toggleGoal(String k) =>
      setState(() => goals.contains(k) ? goals.remove(k) : goals.add(k));

  // ───────────────────────────────────────────────────────────────────────────
  // 감정 선택 + PAD 미세 조정 뷰
  // ───────────────────────────────────────────────────────────────────────────
  Widget _moodSelector() {
    final currentMood = _getCurrentMood();
    final moodEntries = moodToPad.entries.toList();

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

        // 감정 카드: Wrap으로 자동 줄바꿈(데이터 개수 변경에도 견고)
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: [
            for (final entry in moodEntries) _buildMoodCard(entry, currentMood),
          ],
        ),

        const SizedBox(height: 20),
        _padFineTuner(), // 하단: PAD 미세 조정(0.1 step)
      ],
    );
  }

  // 감정 카드(이모지+라벨). 탭하면 해당 감정의 PAD 기본값을 즉시 적용.
  Widget _buildMoodCard(
    MapEntry<String, Map<String, dynamic>> entry,
    String currentMood,
  ) {
    final moodName = entry.key;
    final moodData = entry.value;
    final emoji = moodData["emoji"] as String;
    final isSelected = moodName == currentMood;

    // 4열 레이아웃을 대략 맞추기 위해 가로 폭을 계산
    final cardWidth = (MediaQuery.of(context).size.width - 20 - 20 - 8 * 3) / 4;

    return SizedBox(
      width: cardWidth,
      child: GestureDetector(
        onTap: () {
          // 선택 시 해당 감정의 PAD를 기본값으로 세팅
          setState(() {
            p = moodData["p"] as double;
            a = moodData["a"] as double;
            d = moodData["d"] as double;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? _pastelBlueBase.withValues(alpha: 0.12) // 부드러운 하이라이트
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

  // PAD 세밀 조정(−2.0 ~ 2.0, 0.1 step) 슬라이더 묶음
  Widget _padFineTuner() {
    // 내부 헬퍼: 동일한 슬라이더 스펙을 축별로 재사용
    Widget sliderRow({
      required String label,
      required double value,
      required ValueChanged<double> onChanged,
      required IconData icon,
      required Color base, // 축별 베이스 컬러(파스텔)
    }) {
      // 파스텔톤 파생값: 트랙/썸/오버레이/칩 등
      final active = base.withValues(alpha: 0.75); // 활성 트랙/썸
      final overlay = base.withValues(alpha: 0.14); // 드래그 오버레이
      final chipBg = base.withValues(alpha: 0.10); // 값 표시 배경

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨 + 우측 미세증감 버튼/현재값
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
          // 파스텔 슬라이더 테마
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: active, // 활성 트랙(파스텔)
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.25),
              thumbColor: active, // 썸도 파스텔
              overlayColor: overlay, // 드래그 시 오버레이
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value,
              min: -2.0,
              max: 2.0,
              divisions: 40, // 0.1 step
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
            base: _pastelGreenBase, // P는 초록 계열(긍/쾌) 연상
          ),
          sliderRow(
            label: 'A (Arousal)  차분 ↔ 흥분',
            value: a,
            onChanged: (v) => setState(() => a = v),
            icon: Icons.flash_on,
            base: _pastelOrangeBase, // A는 주황 계열(에너지) 연상
          ),
          sliderRow(
            label: 'D (Dominance)  수동 ↔ 능동',
            value: d,
            onChanged: (v) => setState(() => d = v),
            icon: Icons.psychology,
            base: _pastelIndigoBase, // D는 인디고(안정/주도) 연상
          ),
        ],
      ),
    );
  }

  // 미니 +/− 버튼(0.1 단위 증감)
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

  // 에너지 3분할 세그먼트(시맨틱 아이콘 + 파스텔 하이라이트, 프리셋 적용)
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

            // ⬇️ 여기서 프리셋(Mint/Sage/Seafoam) 기반 alias를 적용합니다.
            final bg = isSelected
                ? _selBgBase.withValues(alpha: 0.22) // 은은한 파스텔 배경
                : _surface;
            final brd = isSelected
                ? _selBorder.withValues(alpha: 0.60) // 보더는 배경보다 한 톤 강조
                : Colors.grey.withValues(alpha: 0.28);
            final txtC = isSelected
                ? _selBase.withValues(alpha: 0.95) // 텍스트/아이콘 포인트
                : _textSecondary;
            final shd = isSelected
                ? _selShadow.withValues(alpha: 0.10) // 살짝만 드롭섀도
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
    // 안전/호환성: viewPaddingOf 대신 of(context).viewPadding 사용
    final padInset = MediaQuery.of(context).viewPadding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('감정 인사이트 설정'),
        actions: [
          TextButton(
            onPressed: () {
              // ⚠️ 타입 주의: RankRequest.pad 필드가 double이라고 가정.
              //    만약 int이면 아래처럼 반올림/변환 필요:
              //    pleasure: (p * 10).round() / 10.0  (DB 스키마가 double이면)
              final updated = widget.initial.copyWith(
                pad: widget.initial.pad.copyWith(
                  pleasure: p, // double 필드 가정
                  arousal: a,
                  dominance: d,
                ),
                energy: energy,
                // 사회성 필요도는 여전히 0.5 step. 표시와 저장을 1자리로 통일.
                socialNeed: double.parse(socialNeed.toStringAsFixed(1)),
                goals: goals.toList(),
              );
              Navigator.pop(context, updated);
            },
            child: const Text('저장'),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          // 상하 그러데이션: 파스텔 톤으로 매우 약하게
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

                // 에너지 3분할 (Mint/Sage/Seafoam 프리셋 적용)
                _seg3('에너지', energy, (v) => setState(() => energy = v)),
                const SizedBox(height: 24),

                // 사회성 필요도
                const Text(
                  '사회성 필요도',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

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
                      // 좌/우 아이콘 라벨(혼자 ↔ 함께)
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

                      // 파스텔 톤 SliderTheme
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
                          divisions: 4, // -1, -0.5, 0, 0.5, 1.0
                          label: socialNeed.toStringAsFixed(1),
                          onChanged: (v) => setState(
                            () =>
                                socialNeed = double.parse(v.toStringAsFixed(1)),
                          ),
                        ),
                      ),

                      // 현재값 칩(파스텔 배경)
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

                // 여행 목표 Chip들
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
                  children: _goalDefs.map((g) {
                    final key = g.$1;
                    final label = g.$2;
                    final selected = goals.contains(key);
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
